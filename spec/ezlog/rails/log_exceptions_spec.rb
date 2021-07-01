RSpec.describe Ezlog::Rails::LogExceptions do
  include_context 'Middleware' do
    subject(:middleware) { described_class.new app, Ezlog.logger('LogExceptions') }
  end

  describe '#call' do
    context 'when there is an exception' do
      let(:app_call) { -> { raise Exception, 'test message' } }

      it 'logs the exception and allows it to pass through' do
        expect { call }.to raise_error(Exception, 'test message').and log(message: 'test message',
                                                                          logger: 'LogExceptions').at_level(:error)
      end

      context 'that is included in ActionDispatch::ExceptionWrapper.rescue_responses' do
        let(:app_call) { -> { raise ActionController::UnknownHttpMethod, 'unknown method' } }

        it 'does not log the exception but allows it to pass through' do
          expect { call }.to raise_error(ActionController::UnknownHttpMethod, 'unknown method')
                               .and not_log(logger: 'LogExceptions').at_level(:error)
        end
      end
    end
  end
end
