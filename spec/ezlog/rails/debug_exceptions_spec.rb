RSpec.describe Ezlog::Rails::DebugExceptions do
  subject(:debugger) { described_class.new nil }

  it 'is an ActionDispatch::DebugExceptions descendant' do
    expect(subject).to be_an ActionDispatch::DebugExceptions
  end

  describe '#log_error' do
    it 'does not log anything' do
      expect { debugger.log_error nil, nil }.not_to change { log_output }
    end
  end
end
