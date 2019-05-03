require 'sidekiq'

module Ezlog
  module Sidekiq
    class JobLogger
      def call(item, queue)
        logger.info log_message(item, 'Job started')
        yield
      end

      private

      def log_message(job, message)
        basic_info_for(job)
          .merge(arguments_of(job))
          .merge(message: message)
      end

      def basic_info_for(job)
        {
          'jid' => job['jid'],
          'queue' => job['queue'],
          'worker' => job['class'],
          'created_at' => job['created_at'],
          'enqueued_at' => job['enqueued_at']
        }
      end

      def arguments_of(job)
        {}.tap do |arguments|
          perform_parameters_of(job).each_with_index do |(_, param_name), index|
            arguments[param_name] = job['args'][index]
          end
        end
      end

      def perform_parameters_of(job)
        Kernel.const_get(job['class'].to_sym).instance_method(:perform).parameters
      end

      def logger
        ::Sidekiq.logger
      end
    end
  end
end
