RSpec.describe Ezlog::Sidekiq::JobLogger do
  include_context 'Sidekiq'

  let(:job_logger) { Ezlog::Sidekiq::JobLogger.new }
  let(:job_hash) { sidekiq_job_hash jid: 'job ID' }

  describe '#call' do
    it 'yields the block it was called with' do
      expect { |block| job_logger.call(job_hash, :queue, &block) }.to yield_control
    end

    it 'logs a start message including the job context' do
      expect { job_logger.call(job_hash, :queue) {} }.to log(message: 'TestWorker started', jid: 'job ID').at_level(:info)
    end

    it 'logs the start message before dispatching the job' do
      job_logger.call(job_hash, :queue) do
        log_output_is_expected.to include_log_message message: 'TestWorker started'
      end
    end

    it 'logs a finish message with job context and timing' do
      allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(1.0, 3.666666)
      expect { job_logger.call(job_hash, :queue) {} }.to log(message: 'TestWorker finished',
                                                             jid: 'job ID',
                                                             duration_sec: 2.667).at_level(:info)
    end

    context 'when the job itself logs a message' do
      let(:call_with_logging) { job_logger.call(job_hash, :queue) { Sidekiq.logger.info 'Message during processing' } }

      it 'includes the context information of the job' do
        expect { call_with_logging }.to log(message: 'Message during processing', jid: 'job ID').at_level(:info)
      end
    end

    context 'when something is logged after the job is finished' do
      it "does not include the - already executed - job's context information" do
        job_logger.call(job_hash, :queue) {}
        expect { Sidekiq.logger.info 'Message after processing' }.not_to log message: 'Message after processing',
                                                                             jid: 'job ID'
      end
    end

    context 'when there is an error processing the job' do
      let(:call_with_exception) { job_logger.call(job_hash, :queue) { raise Exception } }

      it 'lets the error through and logs a failure message with job context and timing' do
        allow(::Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(1.0, 2.0)
        expect { call_with_exception }.to raise_error(Exception).and log(message: 'TestWorker failed',
                                                                         jid: 'job ID',
                                                                         duration_sec: 1.0).at_level(:info)
      end
    end
  end

  describe '#with_job_hash_context' do
    it 'yields the block that was passed - for compatibility with Sidekiq 6' do
      expect { |block| job_logger.with_job_hash_context job_hash, &block }.to yield_control
    end
  end

  describe '#prepare' do
    it 'yields the block that was passed - for compatibility with Sidekiq 6.0.1' do
      expect { |block| job_logger.prepare job_hash, &block }.to yield_control
    end

    context 'with worker-specific log levels' do
      let(:prepare_with_debug_logging) { job_logger.prepare(job_hash) { Sidekiq.logger.debug '1st debug message' } }

      before { Sidekiq.logger.level = :info }

      context 'when no worker-specific log level is set' do
        it "uses the logger's log level" do
          expect { prepare_with_debug_logging }.not_to log(message: '1st debug message').at_level(:debug)
        end
      end

      context 'when a worker-specific log level is set' do
        before { job_hash['log_level'] = :debug }

        it "adjusts the logger's log level" do
          expect { prepare_with_debug_logging }.to log(message: '1st debug message').at_level(:debug)
        end

        it "resets the logger's log level after the job is done" do
          prepare_with_debug_logging
          expect { Sidekiq.logger.debug '2nd debug message' }.not_to log message: '2nd debug message'
        end
      end
    end
  end
end
