RSpec.describe Ezlog::Rails::LogExceptions do
  subject(:middleware) { described_class.new app, Ezlog.logger('LogExceptions') }
  let(:app) { double 'application' }

  describe '#call' do
    subject(:call) { middleware.call env }
    let(:env) { double 'environment' }

    it 'calls the next middleware in the stack and returns the results' do
      call_result = double 'status, headers, body'
      allow(app).to receive(:call).with(env).and_return(call_result)
      expect(call).to eq call_result
    end

    context 'when there is an exception' do
      before { allow(app).to receive(:call).and_raise Exception, 'test message' }

      it 'logs the exception and allows it to pass through' do
        expect { call }.to raise_error(Exception, 'test message').and log(message: 'test message',
                                                                          logger: 'LogExceptions').at_level(:error)
      end
    end
  end
end
