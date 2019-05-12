module Ezlog
  class Railtie < Rails::Railtie
    initializer 'ezlog.configure_logging' do |app|
      ::Logging.logger.root.appenders = ::Logging.appenders.stdout 'stdout',
                                                                   layout: Ezlog::LoggingLayout.new(environment: Rails.env),
                                                                   level: app.config.log_level || :info
    end

    initializer 'ezlog.configure_sidekiq_logging' do
      initialize_sidekiq_logging if defined? ::Sidekiq
    end

    initializer 'ezlog.configure_rack_timeout_logging' do
      initialize_rack_timeout_logging if defined? ::Rack::Timeout
    end

    config.before_configuration do |app|
      app.config.logger = ::Logging.logger['Application']
    end

    private

    def initialize_sidekiq_logging
      ::Sidekiq.logger = Logging.logger['Sidekiq']
      ::Sidekiq.logger.level = :info
      ::Sidekiq.configure_server do |config|
        require 'ezlog/sidekiq/job_logger'
        config.options[:job_logger] = Ezlog::Sidekiq::JobLogger
      end
    end

    def initialize_rack_timeout_logging
      ::Rack::Timeout::Logger.logger = ::Logging.logger['rack-timeout']
      ::Rack::Timeout::Logger.logger.level = :warn
    end
  end
end
