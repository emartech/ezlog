module Ezlog
  module Rails
    class AccessLog
      include LogContextHelper

      def initialize(app, logger, whitelisted_params)
        @app = app
        @logger = logger
        @whitelisted_params = whitelisted_params&.map &:to_s
      end

      def call(env)
        status, headers, body_lines = benchmark { @app.call(env) }
        log_request ActionDispatch::Request.new(env), status
        [status, headers, body_lines]
      rescue Exception => ex
        log_request ActionDispatch::Request.new(env), ActionDispatch::ExceptionWrapper.status_code_for_exception(ex.class.name)
        raise
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
        @logger.info message: '%s %s - %i (%s)' % [request.method, request.filtered_path, status, Rack::Utils::HTTP_STATUS_CODES[status]],
                     remote_ip: request.remote_ip,
                     method: request.method,
                     path: request.filtered_path,
                     params: params_to_log_in(request),
                     params_serialized: request.filtered_parameters.inspect,
                     response_status_code: status
      end

      def params_to_log_in(request)
        if @whitelisted_params.nil?
          request.filtered_parameters
        else
          request.filtered_parameters.slice *@whitelisted_params
        end
      end
    end
  end
end
