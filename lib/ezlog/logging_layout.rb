require 'time'
require 'multi_json'

module Ezlog
  class LoggingLayout < ::Logging::Layout
    def initialize(context = {})
      @initial_context = context
    end

    def format(event)
      log_entry = basic_information_for event
      add_initial_context_to log_entry
      add_logging_context_to log_entry
      add_event_information_to log_entry, event
      ::MultiJson.dump(log_entry) + "\n"
    end

    private

    def basic_information_for(event)
      {
        'logger' => event.logger,
        'timestamp' => event.time.iso8601,
        'level' => ::Logging::LNAMES[event.level],
        'hostname' => Socket.gethostname,
        'pid' => Process.pid
      }
    end

    def add_initial_context_to(log_entry)
      log_entry.merge! @initial_context
    end

    def add_logging_context_to(log_entry)
      log_entry.merge! ::Logging.mdc.context
    end

    def add_event_information_to(log_entry, event)
      log_entry.merge! hash_from(event.data)
    end

    def hash_from(obj)
      case obj
      when Exception
        exception_message_by(obj)
      when Hash
        obj
      else
        {message: obj}
      end
    end

    def exception_message_by(exception)
      {
        message: exception.message,
        error: {
          class: exception.class.name,
          message: exception.message,
          backtrace: exception.backtrace&.first(20)
        }
      }
    end
  end
end
