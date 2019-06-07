RSpec.shared_context 'Middleware' do
  subject(:middleware) { described_class.new app }
  let(:app) { double 'application' }

  let(:env) { {} }
  let(:call) { middleware.call env }

  let(:status) { double 'status' }
  let(:headers) { double 'headers' }
  let(:body) { double 'body' }

  let(:app_call) { -> { [status, headers, body] } }

  before { allow(app).to receive(:call).with(env) { app_call.call } }

  describe '#call' do
    it 'calls the next middleware in the stack and returns the results' do
      expect(call).to eq [status, headers, body]
    end
  end
end
