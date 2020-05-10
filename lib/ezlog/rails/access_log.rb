module Ezlog
  module Rails
    class AccessLog
      include LogContextHelper

      def initialize(app, logger, config)
        @app = app
        @logger = logger
        @config = config
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
        return if path_ignored?(request)

        message = {
          message: '%s %s - %i (%s)' % [request.method, request.filtered_path, status, Rack::Utils::HTTP_STATUS_CODES[status]],
          remote_ip: request.remote_ip,
          method: request.method,
          path: request.filtered_path,
          params: params_to_log(request),
          response_status_code: status
        }
        message.merge! params_serialized: request.filtered_parameters.inspect if @config.log_only_whitelisted_params
        @logger.info message
      end

      def path_ignored?(request)
        @config.exclude_paths.any? do |pattern|
          case pattern
          when Regexp
            pattern.match? request.path
          else
            pattern == request.path
          end
        end
      end

      def params_to_log(request)
        if @config.log_only_whitelisted_params
          request.filtered_parameters.slice *@config.whitelisted_params&.map(&:to_s)
        else
          request.filtered_parameters
        end
      end
    end
  end
end
