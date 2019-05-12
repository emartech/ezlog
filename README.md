# Ezlog

Ezlog is intended to be a zero-configuration logging setup for pure Ruby or Rails projects using 
[Sidekiq](https://github.com/mperham/sidekiq), [Rack::Timeout](https://github.com/heroku/rack-timeout),
[Sequel](https://sequel.jeremyevans.net/), etc. It uses Tim Pease's wonderful [Logging](https://github.com/TwP/logging)
gem for an all-purpose logging solution.

Ezlog's purpose is threefold:
1. Make sure that our applications are logging in a sensible manner; emitting no unnecessary "noise" but containing all 
relevant and necessary information (like timing).
2. Make sure that all log messages are written to STDOUT in a machine-processable format (JSON) across all of our projects.
3. Achieving the above goal should require no configuration in the projects where the library is used.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ezlog'
```

## What it does

* Initializes the [Logging](https://github.com/TwP/logging) library
* Configures Rails logging
* Configures Sidekiq logging
* Configures Rack::Timeout logging

#### Initializes the Logging library

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
#=> {"logger":"App","timestamp":"2019-05-11T16:08:38+02:00","level":"INFO","hostname":"MacbookPro.local","pid":71674,"message":"Error message","error":{"class":"StandardError","message":"Error message","backtrace":[...]}}
```

#### Configures Rails logging

Ezlog configures the `Rails.logger` to be an instance of a [Logging](https://github.com/TwP/logging) logger by the name 
of `Application`, behaving as described above. The logger uses the log level set in `application.rb` (if present) or 
uses INFO as a default log level. It also adds the environment (`Rails.env`) to the logger's initial context, meaning
it will automatically be appended to all log messages emitted by the application.

#### Configures Sidekiq logging

Ezlog configures the `Sidekiq.logger` to be an instance of a [Logging](https://github.com/TwP/logging) logger by the name
of `Sidekiq`, behaving as described above. It also comes with its own job logger for [Sidekiq](https://github.com/mperham/sidekiq) 
which does several things that come in very handy when working with background jobs.
 
* It emits two log messages per job run; one when the job is started and another one when the job is finished (successfully or unsuccessfuly).
* It measures the time it took to execute the job and appends the benchmark information to the final log message.
* It adds all basic information about the job (worker, queue, JID, created_at, enqueued_at) to the log context so
all log messages emitted during the execution of the job will contain this information.
* It also adds all of the job's parameters (by name) to the log context, which means that all log messages emitted 
during the execution of the job will contain this information as well.

```ruby
class TestWorker
  def perform(customer_id)
    logger.warn 'Customer not found'
  end
end

TestWorker.perform_async 42

#=> {"logger":"Sidekiq","timestamp":"2019-05-12T10:38:10+02:00","level":"INFO","hostname":"MacbookPro.local","pid":75538,"jid":"abcdef1234567890","queue":"default","worker":"TestWorker","created_at":"2019-05-12 10:38:10 +0200","enqueued_at":"2019-05-12 10:38:10 +0200","customer_id":42,"message":"TestWorker started"}
#=> {"logger":"Sidekiq","timestamp":"2019-05-12T10:38:10+02:00","level":"WARN","hostname":"MacbookPro.local","pid":75538,"jid":"abcdef1234567890","queue":"default","worker":"TestWorker","created_at":"2019-05-12 10:38:10 +0200","enqueued_at":"2019-05-12 10:38:10 +0200","customer_id":42,"message":"Customer not found"}
#=> {"logger":"Sidekiq","timestamp":"2019-05-12T10:38:12+02:00","level":"INFO","hostname":"MacbookPro.local","pid":75538,"jid":"abcdef1234567890","queue":"default","worker":"TestWorker","created_at":"2019-05-12 10:38:10 +0200","enqueued_at":"2019-05-12 10:38:10 +0200","customer_id":42,"duration_sec":2.667,"message":"TestWorker finished"}
```

#### Configures Rack::Timeout logging

[Rack::Timeout](https://github.com/heroku/rack-timeout) is a very useful tool for people running services on Heroku
but it is way too verbose by default. What Ezlog does is simply reconfigure its logging to use Ezlog's logging
mechanism and to only output messages at or above WARN level. 

## Disclaimer

Ezlog is highly opinionated software and does in no way aim or claim to be useful for everyone. Use at your own discretion.

## License

The gem is available as open source under the terms of the MIT License - see the [LICENSE](/LICENSE.txt) file for the full text.
