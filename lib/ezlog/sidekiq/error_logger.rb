require 'sidekiq'

module Ezlog
  module Sidekiq
    class ErrorLogger
      def call(error, job_hash)
        ::Sidekiq.logger.warn error
      end
    end
  end
end
