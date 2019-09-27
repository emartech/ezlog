RSpec.describe Ezlog::Sidekiq::LoggerExtension do
  subject(:sidekiq_logger) { logger.extend Ezlog::Sidekiq::LoggerExtension }
  let(:logger) { Ezlog.logger 'Sidekiq' }

  describe '#with_context' do
    it 'executes the given block within the log context' do
      sidekiq_logger.with_context job: 'hash' do
        sidekiq_logger.info 'test'
      end

      log_output_is_expected.to include_log_message message: 'test', job: 'hash'
    end
  end
end
