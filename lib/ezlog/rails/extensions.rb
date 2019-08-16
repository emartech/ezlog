module ActionDispatch
  class DebugExceptions
    def skip_logging_error(_request, _wrapper)
    end

    alias_method :original_log_error, :log_error
    alias_method :log_error, :skip_logging_error
  end
end
