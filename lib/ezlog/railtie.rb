module Ezlog
  class Railtie < Rails::Railtie
    initializer 'ezlog.configure_logging' do |app|
      ::Logging.logger.root.appenders = ::Logging.appenders.stdout 'stdout',
                                                                   layout: Ezlog::LoggingLayout.new(environment: ::Rails.env),
                                                                   level: app.config.log_level || :info
    end

    initializer 'ezlog.configure_sidekiq_logging' do
      initialize_sidekiq_logging if defined? ::Sidekiq
    end

    initializer 'ezlog.configure_rack_timeout_logging' do
      initialize_rack_timeout_logging if defined? ::Rack::Timeout
    end

    config.before_configuration do |app|
      rails_logger = Ezlog.logger('Application')
      app.config.logger = rails_logger
      app.config.middleware.insert_after ::ActionDispatch::RequestId, Ezlog::Rails::RequestLogContext
      app.config.middleware.swap ::Rails::Rack::Logger, Ezlog::Rails::AccessLog, Ezlog.logger('AccessLog')
      app.config.middleware.swap ::ActionDispatch::DebugExceptions, Ezlog::Rails::DebugExceptions
      app.config.middleware.insert_after Ezlog::Rails::DebugExceptions, Ezlog::Rails::LogExceptions, rails_logger
    end

    private

    def initialize_sidekiq_logging
      ::Sidekiq.logger = ::Logging.logger['Sidekiq']
      ::Sidekiq.logger.level = :info
      ::Sidekiq.configure_server do |config|
        config.options[:job_logger] = Ezlog::Sidekiq::JobLogger
        config.error_handlers << Ezlog::Sidekiq::ErrorLogger.new
        config.error_handlers.delete_if { |handler| handler.is_a? ::Sidekiq::ExceptionHandler::Logger }
      end
    end

    def initialize_rack_timeout_logging
      ::Rack::Timeout::Logger.logger = ::Logging.logger['rack-timeout']
      ::Rack::Timeout::Logger.logger.level = :warn
    end
  end
end
