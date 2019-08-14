require 'logging'
require 'rspec/logging_helper'
require_relative 'rspec/helpers'
require_relative 'rspec/matchers'
require_relative 'logging_layout'

RSpec.configure do |config|
  config.include Ezlog::RSpec::Helpers
  config.before(:suite) do
    Logging.appenders.string_io('__ezlog_stringio__', layout: Ezlog::LoggingLayout.new)
    config.capture_log_messages to: '__ezlog_stringio__'
  end
end
