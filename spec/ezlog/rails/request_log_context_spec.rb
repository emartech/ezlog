RSpec.describe Ezlog::Rails::RequestLogContext do
  subject(:middleware) { described_class.new app }
  let(:app) { double 'application' }

  describe '#call' do
    subject(:call) { middleware.call env }
    let(:env) { {'action_dispatch.request_id' => 'unique request ID'} }
    let(:app_call) { -> { call_result } }
    let(:call_result) { double 'status, headers, body' }

    before { allow(app).to receive(:call).with(env) { app_call.call } }

    it 'calls the next middleware in the stack and returns the results' do
      expect(call).to eq call_result
    end

    context 'when the application logs something' do
      let(:app_call) do
        -> do
          Ezlog.logger('Application').info 'test message'
          call_result
        end
      end

      it 'adds the request ID to the log context' do
        expect { call }.to log(message: 'test message',
                               request_id: 'unique request ID')
      end
    end
  end
end
