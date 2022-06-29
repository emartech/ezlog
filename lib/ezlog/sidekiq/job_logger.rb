require 'sidekiq'

module Ezlog
  module Sidekiq
    class JobLogger
      include LogContextHelper

      def initialize(logger = ::Sidekiq.logger)
        @logger = logger
      end

      def call(job_hash, _queue)
        within_log_context(JobContext.from_job_hash(job_hash)) do
          begin
            @logger.info "#{job_hash['class']} started"
            benchmark { yield }
            @logger.info message: "#{job_hash['class']} finished"
          rescue Exception
            @logger.info message: "#{job_hash['class']} failed"
            raise
          end
        end
      end

      def with_job_hash_context(_job_hash, &_block)
        yield
      end

      def prepare(job_hash, &_block)
        old_log_level = @logger.level
        @logger.level = job_hash['log_level'] || @logger.level
        yield
      ensure
        @logger.level = old_log_level
      end

      private

      def benchmark
        start_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        yield
      ensure
        end_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        add_to_log_context duration_sec: (end_time - start_time).round(3)
      end
    end
  end
end
