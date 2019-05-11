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
      expect { job_logger.call(item, queue) {} }.to log(message: 'TestWorker started',
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
        log_output_is_expected.to include_log_message message: 'TestWorker started'
      end
    end

    it 'logs a finish message with timing' do
      allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(1.0, 3.666666)
      expect { job_logger.call(item, queue) {} }.to log(message: 'TestWorker finished',
                                                        jid: 'job id',
                                                        queue: 'job queue',
                                                        worker: 'TestWorker',
                                                        customer_id: 1,
                                                        name: 'name param',
                                                        created_at: now,
                                                        enqueued_at: now,
                                                        duration_sec: 2.667).at_level(:info)
    end

    context 'when the job itself logs a message' do
      let(:call_with_logging) { job_logger.call(item, queue) { Sidekiq.logger.info 'Message during processing' } }

      it 'includes the context information of the job' do
        expect { call_with_logging }.to log(message: 'Message during processing',
                                            jid: 'job id',
                                            queue: 'job queue',
                                            worker: 'TestWorker',
                                            customer_id: 1,
                                            name: 'name param',
                                            created_at: now,
                                            enqueued_at: now).at_level(:info)
      end
    end

    context 'when something is logged after the job is finished' do
      it "does not include the - already executed - job's context information" do
        job_logger.call(item, queue) {}
        expect { Sidekiq.logger.info 'Message after processing' }.not_to log message: 'Message after processing',
                                                                             jid: 'job id'
      end
    end

    context 'when there is an error processing the job' do
      let(:call_with_exception) { job_logger.call(item, queue) { raise Exception } }

      it 'lets the error through and logs a failure message with timing' do
        allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(1.0, 2.0)
        expect { call_with_exception }.to raise_error(Exception)
                                            .and log(message: 'TestWorker failed',
                                                     jid: 'job id',
                                                     queue: 'job queue',
                                                     worker: 'TestWorker',
                                                     customer_id: 1,
                                                     name: 'name param',
                                                     created_at: now,
                                                     enqueued_at: now,
                                                     duration_sec: 1.0).at_level(:info)
      end
    end
  end
end
