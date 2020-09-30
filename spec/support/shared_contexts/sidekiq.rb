RSpec.shared_context 'Sidekiq' do
  around do |example|
    if defined? ::Sidekiq
      existing_logger = ::Sidekiq.logger
      ::Sidekiq.logger = ::Logging.logger['Sidekiq']
      example.run
      ::Sidekiq.logger = existing_logger
    else
      example.run
    end
  end

  class TestWorker
    def perform(customer_id, name) end
  end

  module TestWorkers
    class TestWorker
      def perform(export_id, max_size) end
    end
  end

  def sidekiq_job_hash(jid: 'job id',
                       bid: nil,
                       tags: nil,
                       queue: 'job queue',
                       worker: 'TestWorker',
                       args: [],
                       created_at: Time.now,
                       enqueued_at: Time.now)
    {
      'jid' => jid,
      'bid' => bid,
      'tags' => tags,
      'queue' => queue,
      'class' => worker,
      'args' => args,
      'created_at' => created_at,
      'enqueued_at' => enqueued_at
    }.compact
  end
end
