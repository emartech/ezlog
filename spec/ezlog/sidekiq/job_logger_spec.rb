require 'ezlog/sidekiq/job_logger'

RSpec.describe Ezlog::Sidekiq::JobLogger do
  let(:job_logger) { Ezlog::Sidekiq::JobLogger.new }

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
    let(:now) { Time.now }
    let(:item) do
      {
        'jid' => 'job id',
        'queue' => 'job queue',
        'class' => 'TestWorker',
        'args' => [1, 'name param'],
        'created_at' => now,
        'enqueued_at' => now
      }
    end
    let(:queue) { :queue }

    it 'yields the block it was called with' do
      expect { |block| job_logger.call(item, queue, &block) }.to yield_control
    end

    it 'logs a start message' do
      expect { job_logger.call(item, queue) {} }.to log(message: 'Job started',
                                                        jid: 'job id',
                                                        queue: 'job queue',
                                                        worker: 'TestWorker',
                                                        customer_id: 1,
                                                        name: 'name param',
                                                        created_at: now,
                                                        enqueued_at: now).at_level(:info)
    end

    it 'logs the start message before dispatching the job' do
      job_logger.call(item, queue) do
        log_output_is_expected.to include_log_message message: 'Job started'
      end
    end
  end
end
