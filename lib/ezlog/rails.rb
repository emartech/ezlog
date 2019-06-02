require "action_dispatch"

module Ezlog
  module Rails
    autoload :DebugExceptions, 'ezlog/rails/debug_exceptions'
    autoload :LogExceptions, 'ezlog/rails/log_exceptions'
  end
end
