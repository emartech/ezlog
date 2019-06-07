module Ezlog
  module Rails
    class AccessLog
      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      def call(env)
        status, headers, body_lines = @app.call(env)
        log_request ActionDispatch::Request.new(env), status
        [status, headers, body_lines]
      end

      private

      def log_request(request, status)
        @logger.info message: '%s %s -> %i (%s)' % [request.method, request.filtered_path, status, Rack::Utils::HTTP_STATUS_CODES[status]],
                     remote_ip: request.remote_ip,
                     method: request.method,
                     path: request.filtered_path,
                     params: request.filtered_parameters,
                     response_code: status
      end
    end
  end
end
