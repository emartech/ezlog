require "bundler/setup"
require "ezlog"
require 'rspec/logging_helper'

Dir.glob(File.join(File.dirname(__FILE__),'support', '*', '**', '*.rb')).each { |path| require(path) }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RSpec::Helpers::LoggingHelper
  config.include RSpec::LoggingHelper

  config.before(:suite) do
    Logging.appenders.string_io('stringio', layout: Ezlog::LoggingLayout.new)
    config.capture_log_messages to: 'stringio'
  end
end
