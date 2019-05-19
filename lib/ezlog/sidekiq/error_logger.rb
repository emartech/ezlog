require 'sidekiq'

module Ezlog
  module Sidekiq
    class ErrorLogger
      include LogContextHelper

      def call(error, context)
        within_log_context(JobContext.from_job_hash(context[:job])) do
          ::Sidekiq.logger.warn error
        end
      end
    end
  end
end
