RSpec.describe Ezlog::Rails::RequestLogContext do
  include_context 'Middleware'

  describe '#call' do
    let(:env) { {'action_dispatch.request_id' => 'unique request ID'} }
    let(:app_call) do
      -> do
        Ezlog.logger('Application').info 'test message'
        [status, headers, body]
      end
    end

    it 'adds the request ID to the log context' do
      expect { call }.to log(message: 'test message',
                             request_id: 'unique request ID')
    end
  end
end
