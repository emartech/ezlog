module Ezlog
  module Sidekiq
    module LoggerExtension
      include LogContextHelper

      def with_context(context, &block)
        within_log_context context, &block
      end
    end
  end
end
