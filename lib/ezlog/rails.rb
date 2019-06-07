require "action_dispatch"

module Ezlog
  module Rails
    autoload :AccessLog, 'ezlog/rails/access_log'
    autoload :DebugExceptions, 'ezlog/rails/debug_exceptions'
    autoload :LogExceptions, 'ezlog/rails/log_exceptions'
    autoload :RequestLogContext, 'ezlog/rails/request_log_context'
  end
end
