module Ezlog
  module Rails
    class LogExceptions
      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      def call(env)
        @app.call(env)
      rescue Exception => exception
        @logger.error exception unless handled?(exception)
        raise
      end

      private

      def handled?(exception)
        ActionDispatch::ExceptionWrapper.rescue_responses.key? exception.class.name
      end
    end
  end
end
