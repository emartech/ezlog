module Ezlog
  module Rails
    class DebugExceptions < ::ActionDispatch::DebugExceptions
      def log_error(_request, _wrapper)
      end
    end
  end
end
