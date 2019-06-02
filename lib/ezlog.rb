require 'logging'

require 'ezlog/version'
require 'ezlog/railtie' if defined? Rails

module Ezlog
  autoload :LogContextHelper, 'ezlog/log_context_helper'
  autoload :LoggingLayout, 'ezlog/logging_layout'
  autoload :Rails, 'ezlog/rails'
  autoload :Sidekiq, 'ezlog/sidekiq'

  def self.logger(name)
    Logging::Logger[name]
  end
end
