require 'ezlog/version'
require 'ezlog/logging_layout'

require 'ezlog/sidekiq/job_logger' if defined? ::Sidekiq
