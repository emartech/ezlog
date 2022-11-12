require 'sidekiq'

module Ezlog
  module Sidekiq
    class DeathLogger
      include LogContextHelper
      attr_reader :logger

      def initialize(logger = ::Sidekiq.logger)
        @logger = logger
      end

      def call(job, error)
        within_log_context(JobContext.from_job_hash(job)) do
          logger.error error
        end
      end
    end
  end
end
