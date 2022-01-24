module Ezlog
  class Railtie < Rails::Railtie
    config.ezlog = ActiveSupport::OrderedOptions.new
    config.ezlog.enable_sequel_logging = false
    config.ezlog.log_only_whitelisted_params = false
    config.ezlog.whitelisted_params = [:controller, :action]
    config.ezlog.exclude_paths = []
    config.ezlog.initial_context = { environment: ::Rails.env }
    config.ezlog.layout_options = {}

    initializer "ezlog.initialize" do
      require "ezlog/rails/extensions"
    end

    initializer 'ezlog.configure_logging' do |app|
      ::Logging.logger.root.appenders =
        ::Logging.appenders.stdout 'stdout', layout: Ezlog::LoggingLayout.new(app.config.ezlog.initial_context,
                                                                              app.config.ezlog.layout_options)
      ::Logging.logger.root.level = app.config.log_level
    end

    initializer 'ezlog.configure_sidekiq' do |app|
      initialize_sidekiq_logging(app) if defined? ::Sidekiq
    end

    initializer 'ezlog.configure_sequel' do |app|
      ::Sequel::Database.extension :ezlog_logging if defined?(::Sequel) && app.config.ezlog.enable_sequel_logging
    end

    initializer 'ezlog.configure_rack_timeout' do
      disable_rack_timeout_logging if defined? ::Rack::Timeout
    end

    initializer 'ezlog.configure_rails_middlewares' do |app|
      app.config.middleware.insert_after ::ActionDispatch::RequestId, Ezlog::Rails::RequestLogContext
      app.config.middleware.delete ::Rails::Rack::Logger
      app.config.middleware.insert_before ::ActionDispatch::DebugExceptions, Ezlog::Rails::AccessLog, Ezlog.logger('AccessLog'), config.ezlog
      app.config.middleware.insert_after ::ActionDispatch::DebugExceptions, Ezlog::Rails::LogExceptions, Ezlog.logger('Application')
    end

    config.after_initialize do
      case ::Rails::VERSION::MAJOR
      when 6
        ::ActionController::LogSubscriber.detach_from :action_controller
        if defined? ::ActionView
          require 'action_view/log_subscriber' unless defined? ::ActionView::LogSubscriber
          ::ActionView::LogSubscriber.detach_from :action_view
        end
        if defined? ::ActiveRecord
          ::ActiveRecord::LogSubscriber.detach_from :active_record
          Ezlog::Rails::LogSubscriber.attach Ezlog::Rails::ActiveRecord::LogSubscriber, :active_record
        end
      else
        Ezlog::Rails::LogSubscriber.detach ::ActionController::LogSubscriber
        Ezlog::Rails::LogSubscriber.detach ::ActionView::LogSubscriber
        if defined? ::ActiveRecord
          Ezlog::Rails::LogSubscriber.detach ::ActiveRecord::LogSubscriber
          Ezlog::Rails::LogSubscriber.attach Ezlog::Rails::ActiveRecord::LogSubscriber, :active_record
        end
      end
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
        config.death_handlers << Ezlog::Sidekiq::DeathLogger.new
      end
    end

    def disable_rack_timeout_logging
      ::Rack::Timeout::Logger.logger = ::Logger.new(nil)
    end
  end
end
