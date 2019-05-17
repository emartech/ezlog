require 'ezlog/sidekiq/error_logger'

RSpec.describe Ezlog::Sidekiq::ErrorLogger, type: :logger do
  subject(:logger) { Ezlog::Sidekiq::ErrorLogger.new }

  around do |example|
    existing_logger = Sidekiq.logger
    Sidekiq.logger = Logging.logger['Sidekiq']
    example.run
    Sidekiq.logger = existing_logger
  end

  describe '#call' do
    let(:error) { StandardError.new 'error message' }

    it 'logs the error in a single message at WARN level' do
      expect { logger.call(error, {}) }.to log(message: 'error message').at_level(:warning)
    end
  end
end
