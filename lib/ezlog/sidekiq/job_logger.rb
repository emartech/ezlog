require 'sidekiq'

module Ezlog
  module Sidekiq
    class JobLogger
      def call(item, queue)
        within_log_context_of(item) do
          logger.info "#{item['class']} started"
          benchmark { yield }
          logger.info message: "#{item['class']} finished"
        rescue Exception
          logger.info message: "#{item['class']} failed"
          raise
        end
      end

      private

      def within_log_context_of(item)
        Logging.mdc.push log_context(item)
        yield
      ensure
        Logging.mdc.pop
      end

      def log_context(job)
        basic_info_for(job).merge arguments_of(job)
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
          method_parameters_of(job).each_with_index do |(_, param_name), index|
            arguments[param_name] = job['args'][index]
          end
        end
      end

      def method_parameters_of(job)
        Kernel.const_get(job['class'].to_sym).instance_method(:perform).parameters
      end

      def logger
        ::Sidekiq.logger
      end

      def benchmark
        start_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        yield
      ensure
        end_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        Logging.mdc[:duration_sec] = (end_time - start_time).round(3)
      end
    end
  end
end
