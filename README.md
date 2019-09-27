# Ezlog

[![Gem Version](https://badge.fury.io/rb/ezlog.svg)](https://badge.fury.io/rb/ezlog)
[![Build Status](https://travis-ci.com/emartech/ezlog.svg?branch=master)](https://travis-ci.com/emartech/ezlog)

Ezlog is intended to be a zero-configuration structured logging setup for pure Ruby or [Ruby on Rails](https://rubyonrails.org/) 
projects using any (or all) of the following libraries or frameworks:

* [Ruby on Rails](https://rubyonrails.org/)
* [Sidekiq](https://github.com/mperham/sidekiq)
* [Sequel](https://sequel.jeremyevans.net/) 
* [Rack::Timeout](https://github.com/heroku/rack-timeout)

It uses Tim Pease's wonderful [Logging](https://github.com/TwP/logging) gem under the hood for an all-purpose structured logging solution.

Ezlog's purpose is threefold:
1. Make sure that our applications are logging in a concise and sensible manner; emitting no unnecessary "noise" but 
   containing all relevant and necessary information (like timing).
2. Make sure that all log messages are written to STDOUT in a machine-processable format (JSON) across all of our projects.
3. Achieving the above goals should require no configuration in the projects where the library is used.

## Installation

#### Rails

Add this line to your application's Gemfile:

```ruby
gem 'ezlog'
```

Although Ezlog sets up sensible defaults for all logging configuration settings, it leaves you the option to override these
settings manually in the way you're used to; via [Rails](https://rubyonrails.org/)'s configuration mechanism. Unfortunately
the [Rails](https://rubyonrails.org/) new project generator automatically generates code for the production environment
configuration that overrides these settings.

**For Ezlog to work properly, you also need to delete the logging configuration options in the 
`config/environments/production.rb` generated file.**

#### Non-Rails applications

At the moment Ezlog only support [Rails](https://rubyonrails.org/) apps. Non-Rails support is planned.

## What it does

* Initializes the [Logging](https://github.com/TwP/logging) library
* Configures [Rails](https://rubyonrails.org/)'s logging
* Configures [Sidekiq](https://github.com/mperham/sidekiq) logging
* Configures [Rack::Timeout](https://github.com/heroku/rack-timeout) logging
* Provides testing support for [RSpec](https://rspec.info/)

### Initializes the Logging library

Ezlog sets up [Logging](https://github.com/TwP/logging)'s root logger to have an appender that writes to STDOUT.
Any loggers created by the application will inherit this appender and will thus write their logs to STDOUT.
Ezlog also comes with its own log layout, which it uses to output messages sent to the STDOUT appender. This layout
does several very useful things to make our lives easier:

* It can handle log messages in several formats:
  * String (obviously)
  * Hash
  * Exception
  * any object that can be coerced into a String
* It automatically adds basic information to all log messages, such as:
  * name of the logger
  * timestamp
  * log level (as string)
  * hostname
  * PID

Examples:
```ruby
logger.info 'Log message'
#=> {"logger":"App","timestamp":"2019-05-11T16:08:38+02:00","level":"INFO","hostname":"MacbookPro.local","pid":71674,"message":"Log message"}

logger.info message: 'Job finished', duration: 2
#=> {"logger":"App","timestamp":"2019-05-11T16:08:38+02:00","level":"INFO","hostname":"MacbookPro.local","pid":71674,"message":"Job finished","duration":2}

logger.error ex
#=> {"logger":"App","timestamp":"2019-05-11T16:08:38+02:00","level":"ERROR","hostname":"MacbookPro.local","pid":71674,"message":"Error message","error":{"class":"StandardError","message":"Error message","backtrace":[...]}}
```

### Configures Rails logging

Ezlog configures the `Rails.logger` to be an instance of a [Logging](https://github.com/TwP/logging) logger by the name 
of `Application`, behaving as described above. 

In addition to this, Ezlog also does the following:
* It adds the environment (`Rails.env`) to the logger's initial context, so it will automatically be appended to all log messages 
  emitted by the application.
* It disables Rails's default logging of uncaught errors and injects its own error logger into the application, which
  * logs 1 line per error, including the error's name and context (stack trace, etc.),
  * logs every error at ERROR level instead of the default FATAL.
* It disables Rails's default request logging, which logs several lines per event during the processing of an action,
  and replaces the default Rack access log with its own access log middleware. The end result is an access log that
  * contains all relevant information (request ID, method, path, params, client IP, duration and response status code), and
  * has 1 log line per request, logged at the end of the request.

Thanks to Mathias Meyer for writing [Lograge](https://github.com/roidrage/lograge), which inspired the solution. 
If Ezlog's not your cup of tea but you're looking for a way to tame Rails's logging then be sure to check out
[Lograge](https://github.com/roidrage/lograge). 

```
GET /welcome?subsession_id=34ea8596f9764f475f81158667bc2654

With default Rails logging:

Started GET "/welcome?subsession_id=34ea8596f9764f475f81158667bc2654" for 127.0.0.1 at 2019-06-08 08:49:31 +0200
Processing by PagesController#welcome as HTML
  Parameters: {"subsession_id"=>"34ea8596f9764f475f81158667bc2654"}
  Rendering pages/welcome.html.haml within layouts/application
  Rendered pages/welcome.html.haml within layouts/application (5.5ms)
Completed 200 OK in 31ms (Views: 27.3ms | ActiveRecord: 0.0ms)

With Ezlog:

{"logger":"AccessLog","timestamp":"2019-06-08T08:49:31+02:00","level":"INFO","hostname":"MacbookPro.local","pid":75463,"environment":"development","request_id":"9a43631b-284c-4677-9d08-9c1cc5c7d3a7","duration_sec":0.031,"message":"GET /welcome?subsession_id=34ea8596f9764f475f81158667bc2654 - 200 (OK)","remote_ip":"127.0.0.1","method":"GET","path":"/welcome?subsession_id=34ea8596f9764f475f81158667bc2654","params":{"subsession_id":"34ea8596f9764f475f81158667bc2654","controller":"pages","action":"welcome"},"response_status_code":200}
```

#### The log level

The logger's log level is determined as follows (in order of precedence):
* the log level set in the application's configuration,
* the LOG_LEVEL environment variable, or
* `INFO` as the default log level if none of the above are set.

The following log levels are available: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.

### Configures Sidekiq logging

Ezlog configures the `Sidekiq.logger` to be an instance of a [Logging](https://github.com/TwP/logging) logger by the name
of `Sidekiq`, behaving as described above. The logger uses the same log level as the [Rails](https://rubyonrails.org/) 
logger (see above). Ezlog also comes with its own job logger for [Sidekiq](https://github.com/mperham/sidekiq) 
which does several things that come in very handy when working with background jobs.
 
* It emits two log messages per job run; one when the job is started and another one when the job is finished (successfully or unsuccessfuly).
* It measures the time it took to execute the job and appends the benchmark information to the final log message.
* It adds all basic information about the job (worker, queue, JID, created_at, enqueued_at, run_count) to the log context so
all log messages emitted during the execution of the job will contain this information.
* It also adds all of the job's parameters (by name) to the log context, which means that all log messages emitted 
during the execution of the job will contain this information as well.

```ruby
class TestWorker
  include Sidekiq::Worker

  def perform(customer_id)
    logger.warn 'Customer not found'
  end
end

TestWorker.perform_async 42

#=> {"logger":"Sidekiq","timestamp":"2019-05-12T10:38:10+02:00","level":"INFO","hostname":"MacbookPro.local","pid":75538,"jid":"abcdef1234567890","queue":"default","worker":"TestWorker","created_at":"2019-05-12 10:38:10 +0200","enqueued_at":"2019-05-12 10:38:10 +0200","run_count":1,"customer_id":42,"message":"TestWorker started"}
#=> {"logger":"Sidekiq","timestamp":"2019-05-12T10:38:10+02:00","level":"WARN","hostname":"MacbookPro.local","pid":75538,"jid":"abcdef1234567890","queue":"default","worker":"TestWorker","created_at":"2019-05-12 10:38:10 +0200","enqueued_at":"2019-05-12 10:38:10 +0200","run_count":1,"customer_id":42,"message":"Customer not found"}
#=> {"logger":"Sidekiq","timestamp":"2019-05-12T10:38:12+02:00","level":"INFO","hostname":"MacbookPro.local","pid":75538,"jid":"abcdef1234567890","queue":"default","worker":"TestWorker","created_at":"2019-05-12 10:38:10 +0200","enqueued_at":"2019-05-12 10:38:10 +0200","run_count":1,"customer_id":42,"duration_sec":2.667,"message":"TestWorker finished"}
```

### Configures Rack::Timeout logging

[Rack::Timeout](https://github.com/heroku/rack-timeout) is a very useful tool for people running services on Heroku
but it is way too verbose by default and all of its important messages (i.e. Timeout errors) are logged by the application
as well. For this reason, Ezlog turns off [Rack::Timeout](https://github.com/heroku/rack-timeout) logging completely. 

### Provides testing support for RSpec

Ezlog comes with built-in support for testing your logging activity using [RSpec](https://rspec.info/).
To enable spec support for Ezlog, put this line in your `spec_helper.rb` or `rails_helper.rb`:

```ruby
require "ezlog/rspec"
```

What you get:
* Helpers
  * `log_output` provides access to the complete log output in your specs
  * `log_output_is_expected` shorthand for writing expectations for the log output
* Matchers
  * `include_log_message` matcher for expecting a certain message in the log output
  * `log` matcher for expecting an operation to log a certain message

```ruby
# Check that the log contains a certain message
expect(log_output).to include_log_message message: 'Test message'
log_output_is_expected.to include_log_message message: 'Test message'

# Check that the message is not present in the logs before the operation but is present after it 
expect { operation }.to log message: 'Test message', 
                            user_id: 123456 

# Expect a certain log level
log_output_is_expected.to include_log_message(message: 'Test message').at_level(:info)
expect { operation }.to log(message: 'Test message').at_level(:info)
```

## Disclaimer

Ezlog is highly opinionated software and does in no way aim or claim to be useful for everyone. Use at your own discretion.

## License

The gem is available as open source under the terms of the MIT License - see the [LICENSE](/LICENSE.txt) file for the full text.
