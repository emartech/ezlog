require 'sidekiq'

module Ezlog
  module Sidekiq
    class ErrorLogger
      include LogContextHelper
      attr_reader :logger

      def initialize(logger = ::Sidekiq.logger)
        @logger = logger
      end

      def call(error, context)
        within_log_context(JobContext.from_job_hash(context[:job])) do
          logger.warn error
        end
      end
    end
  end
end
