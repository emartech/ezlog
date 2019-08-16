require "action_controller"
require_relative '../../../lib/ezlog/rails/extensions'

RSpec.describe ActionDispatch::DebugExceptions do
  subject(:debugger) { described_class.new nil }

  describe '#log_error' do
    it 'does not log anything' do
      expect { debugger.log_error nil, nil }.not_to change { log_output }
    end
  end
end
