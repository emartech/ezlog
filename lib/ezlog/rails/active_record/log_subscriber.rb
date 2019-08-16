module Ezlog
  module Rails
    module ActiveRecord
      class LogSubscriber < ::ActiveSupport::LogSubscriber
        def sql(event)
          ::ActiveRecord::Base.logger.debug log_message_from(event)
        end

        private

        def log_message_from(event)
          basic_message_from(event).tap do |message|
            params = params_from event
            message[:params] = params if params.present?
          end
        end

        def basic_message_from(event)
          {
            message: "SQL - #{event.payload[:name]} (#{event.duration.round(3)}ms)",
            sql: event.payload[:sql],
            duration_sec: (event.duration / 1000.0).round(5)
          }
        end

        def params_from(event)
          return if event.payload.fetch(:binds, []).empty?

          names = event.payload[:binds].map(&:name)
          values = event.payload[:type_casted_binds]

          Hash[names.zip(values)]
        end
      end
    end
  end
end
