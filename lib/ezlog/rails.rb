require "action_controller"
require "action_controller/log_subscriber"

module Ezlog
  module Rails
    autoload :AccessLog, 'ezlog/rails/access_log'
    autoload :DebugExceptions, 'ezlog/rails/debug_exceptions'
    autoload :LogExceptions, 'ezlog/rails/log_exceptions'
    autoload :RequestLogContext, 'ezlog/rails/request_log_context'
    autoload :LogSubscriber, 'ezlog/rails/log_subscriber'
  end
end
