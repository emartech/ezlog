require 'active_support/ordered_options'

RSpec.describe Ezlog::Rails::AccessLog do
  include_context 'Middleware' do
    subject(:middleware) { described_class.new app, Ezlog.logger('AccessLog'), config }
    let(:config) { ActiveSupport::InheritableOptions.new config_options }
    let(:config_options) do
      {
        log_only_whitelisted_params: false,
        whitelisted_params: [:controller, :action],
        exclude_paths: []
      }
    end
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

    it 'logs additional information about the request including all parameters' do
      expect { call }.to log logger: 'AccessLog',
                             remote_ip: '127.0.0.1',
                             method: 'GET',
                             path: '/healthcheck?test=true',
                             params: {test: 'true'},
                             response_status_code: 200
    end

    it 'does not log serialized params' do
      expect { call }.not_to log params_serialized: '{"test"=>"true"}'
    end

    it 'logs the request duration' do
      allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(1.0, 3.666666)
      expect { call }.to log duration_sec: 2.667
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

    context 'when there are params that are not whitelisted' do
      before do
        config.log_only_whitelisted_params = true
        config.whitelisted_params << :allowed
        env['QUERY_STRING'] = 'allowed=1&not_allowed=2'
      end

      it 'logs only the whitelisted params' do
        expect { call }.to log params: {allowed: '1'}
      end

      it 'logs all parameters serialized' do
        expect { call }.to log params_serialized: '{"allowed"=>"1", "not_allowed"=>"2"}'
      end
    end

    context 'when a path is ignored' do
      context 'and the ignored path is a string' do
        before { config.exclude_paths << '/healthcheck' }

        it 'does not log anything for that path' do
          call
          log_output_is_expected.to be_empty
        end
      end

      context 'and the ignored path is a regexp' do
        before { config.exclude_paths << %r(/healthcheck) }

        it 'does not log anything for that path' do
          call
          log_output_is_expected.to be_empty
        end
      end
    end
  end
end
