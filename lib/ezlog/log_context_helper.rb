module Ezlog
  module LogContextHelper
    def within_log_context(context)
      Logging.mdc.push context
      yield
    ensure
      Logging.mdc.pop
    end

    def add_to_log_context(context)
      Logging.mdc.update context
    end
  end
end
