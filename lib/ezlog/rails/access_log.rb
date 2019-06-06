module Ezlog
  module Rails
    class AccessLog
      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        status, header, body_lines = @app.call(env)
        @logger.info message: '%s %s -> %i (%s)' % [request.method, request.filtered_path, status, Rack::Utils::HTTP_STATUS_CODES[status]],
                     remote_ip: request.remote_ip,
                     method: request.method,
                     path: request.filtered_path,
                     params: request.filtered_parameters,
                     response_code: status
        [status, header, body_lines]
      end
    end
  end
end
