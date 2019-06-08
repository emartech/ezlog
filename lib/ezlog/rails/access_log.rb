module Ezlog
  module Rails
    class AccessLog
      include LogContextHelper

      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      def call(env)
        status, headers, body_lines = benchmark { @app.call(env) }
        log_request ActionDispatch::Request.new(env), status
        [status, headers, body_lines]
      end

      private

      def benchmark
        start_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        yield
      ensure
        end_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        add_to_log_context duration_sec: (end_time - start_time).round(3)
      end

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
