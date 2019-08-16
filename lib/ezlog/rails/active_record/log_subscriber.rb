module Ezlog
  module Rails
    module ActiveRecord
      class LogSubscriber < ::ActiveSupport::LogSubscriber
        def sql(event)
          ::ActiveRecord::Base.logger.debug message: "SQL - #{event.payload[:name]} (#{event.duration.round(3)}ms)",
                                            sql: event.payload[:sql],
                                            duration_sec: (event.duration / 1000.0).round(5)
        end
      end
    end
  end
end
