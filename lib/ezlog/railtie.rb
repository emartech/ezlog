module Ezlog
  class Railtie < Rails::Railtie
    initializer "ezlog.initialize" do
      require "ezlog/rails/extensions"
    end

    initializer 'ezlog.configure_logging' do |app|
      ::Logging.logger.root.appenders = ::Logging.appenders.stdout 'stdout', layout: Ezlog::LoggingLayout.new(environment: ::Rails.env)
      ::Logging.logger.root.level = app.config.log_level
    end

    initializer 'ezlog.configure_sidekiq_logging' do |app|
      initialize_sidekiq_logging(app) if defined? ::Sidekiq
    end

    initializer 'ezlog.configure_rack_timeout_logging' do
      disable_rack_timeout_logging if defined? ::Rack::Timeout
    end

    initializer 'ezlog.configure_middlewares' do |app|
      app.config.middleware.insert_after ::ActionDispatch::RequestId, Ezlog::Rails::RequestLogContext
      app.config.middleware.delete ::Rails::Rack::Logger
      app.config.middleware.insert_before ::ActionDispatch::DebugExceptions, Ezlog::Rails::AccessLog, Ezlog.logger('AccessLog')
      app.config.middleware.insert_after ::ActionDispatch::DebugExceptions, Ezlog::Rails::LogExceptions, Ezlog.logger('Application')
    end

    config.after_initialize do
      Ezlog::Rails::LogSubscriber.detach ::ActionController::LogSubscriber
      Ezlog::Rails::LogSubscriber.detach ::ActionView::LogSubscriber
    end

    config.before_configuration do |app|
      app.config.logger = Ezlog.logger('Application')
      app.config.log_level = ENV['LOG_LEVEL'] || :info
    end

    private

    def initialize_sidekiq_logging(app)
      ::Sidekiq.logger = Ezlog.logger('Sidekiq')
      ::Sidekiq.logger.level = app.config.log_level
      ::Sidekiq.configure_server do |config|
        config.options[:job_logger] = Ezlog::Sidekiq::JobLogger
        config.error_handlers << Ezlog::Sidekiq::ErrorLogger.new
        config.error_handlers.delete_if { |handler| handler.is_a? ::Sidekiq::ExceptionHandler::Logger }
      end
    end

    def disable_rack_timeout_logging
      ::Rack::Timeout::Logger.logger = ::Logger.new(nil)
    end
  end
end
