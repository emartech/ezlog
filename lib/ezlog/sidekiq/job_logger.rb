require 'sidekiq'

module Ezlog
  module Sidekiq
    class JobLogger
      include LogContextHelper

      def call(job_hash, _queue)
        within_log_context(JobContext.from_job_hash(job_hash)) do
          begin
            logger.info "#{job_hash['class']} started"
            benchmark { yield }
            logger.info message: "#{job_hash['class']} finished"
          rescue Exception
            logger.info message: "#{job_hash['class']} failed"
            raise
          end
        end
      end

      private

      def benchmark
        start_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        yield
      ensure
        end_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        add_to_log_context duration_sec: (end_time - start_time).round(3)
      end

      def logger
        ::Sidekiq.logger
      end
    end
  end
end
