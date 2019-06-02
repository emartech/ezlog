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
        @logger.error exception
        raise
      end
    end
  end
end
