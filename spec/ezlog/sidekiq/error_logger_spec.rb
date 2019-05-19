RSpec.describe Ezlog::Sidekiq::ErrorLogger, type: :logger do
  subject(:logger) { Ezlog::Sidekiq::ErrorLogger.new }

  class TestWorker
    def perform(customer_id, name)
    end
  end

  around do |example|
    existing_logger = Sidekiq.logger
    Sidekiq.logger = Logging.logger['Sidekiq']
    example.run
    Sidekiq.logger = existing_logger
  end

  describe '#call' do
    subject(:call) { logger.call StandardError.new('error message'), {job: job_hash} }
    let(:job_hash) do
      {
        'jid' => 'job id',
        'queue' => 'job queue',
        'class' => 'TestWorker',
        'args' => [1, 'name param'],
        'created_at' => Time.now,
        'enqueued_at' => Time.now
      }
    end

    it 'logs the error in a single message at WARN level' do
      expect { call }.to log(message: 'error message').at_level(:warning)
    end

    it 'logs the job context' do
      expect { call }.to log jid: 'job id'
    end
  end
end
