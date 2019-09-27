module Ezlog
  module Sidekiq
    autoload :ErrorLogger, 'ezlog/sidekiq/error_logger'
    autoload :JobContext, 'ezlog/sidekiq/job_context'
    autoload :JobLogger, 'ezlog/sidekiq/job_logger'
    autoload :LoggerExtension, 'ezlog/sidekiq/logger_extension'
  end
end
