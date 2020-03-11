RSpec.describe Ezlog::Rails::AccessLog do
  include_context 'Middleware' do
    subject(:middleware) { described_class.new app, Ezlog.logger('AccessLog'), whitelisted_params }
    let(:whitelisted_params) { nil }
    let(:env) do
      {
        'REQUEST_METHOD' => 'GET',
        'QUERY_STRING' => 'test=true',
        'PATH_INFO' => '/healthcheck',
        'action_dispatch.remote_ip' => '127.0.0.1',
        'rack.input' => StringIO.new('')
      }
    end
    let(:status) { 200 }
  end

  describe '#call' do
    after { Logging.mdc.clear }

    it 'logs the request path and result as a message' do
      expect { call }.to log message: 'GET /healthcheck?test=true - 200 (OK)'
    end

    it 'logs additional information about the request' do
      expect { call }.to log logger: 'AccessLog',
                             remote_ip: '127.0.0.1',
                             method: 'GET',
                             path: '/healthcheck?test=true',
                             params: {test: 'true'},
                             response_status_code: 200
    end

    it 'logs the request duration' do
      allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(1.0, 3.666666)
      expect { call }.to log duration_sec: 2.667
    end

    context 'when there are params that are not whitelisted' do
      let(:whitelisted_params) { [:allowed] }
      before { env['QUERY_STRING'] = 'allowed=1&not_allowed=2' }

      it 'logs only the whitelisted params' do
        expect { call }.to log params: {allowed: '1'}
      end

      it 'logs all parameters serialized' do
        expect { call }.to log params_serialized: '{\"allowed\"=>\"1\", \"not_allowed\"=>\"2\"}'
      end
    end

    context 'when whitelisting is turned off' do
      let(:whitelisted_params) { nil }
      before { env['QUERY_STRING'] = 'allowed=1&not_allowed=2' }

      it 'logs all params' do
        expect { call }.to log params: {allowed: '1', not_allowed: '2'}
      end
    end

    context 'when the params contain sensitive information' do
      before do
        env['QUERY_STRING'] = 'password=test_pass'
        env['action_dispatch.parameter_filter'] = [:password]
      end

      it 'logs the request path with sensitive information filtered out' do
        expect { call }.to log message: 'GET /healthcheck?password=[FILTERED] - 200 (OK)'
      end

      it 'logs the request params with sensitive information filtered out' do
        expect { call }.to log params: {password: '[FILTERED]'}
      end
    end

    context 'when the request raises an exception' do
      let(:app_call) { -> { raise Exception, 'test error' } }

      it 'logs the request and reraises the error' do
        expect { call }.to raise_error(Exception, 'test error')
                             .and log(message: 'GET /healthcheck?test=true - 500 (Internal Server Error)')
      end
    end
  end
end
