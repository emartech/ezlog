module Ezlog
  module Sequel
    module LoggingExtension
      def self.extended(db)
        db.instance_exec do
          self.sql_log_level = :debug
          self.log_connection_info = false
          @loggers << Ezlog.logger('Sequel')
        end
      end
    end

    ::Sequel::Database.register_extension :ezlog_logging, LoggingExtension
  end
end
