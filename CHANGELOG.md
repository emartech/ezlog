### 0.4.0 (2019-09-06)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.3.5...v0.4.0)

* Features & enhancements
  * Added log context management methods `within_log_context` and `add_to_log_context` to Ezlog module.
  * Replaced ActiveRecord query logging with a log subscriber that logs queries via Ezlog.
  * Added automatic query logging (at DEBUG level) to Sequel connections.
  
* Bug fixes
  * ActionDispatch::DebugExceptions is no longer replaced because other gems 
    (like [web-console](https://github.com/rails/web-console)) are depending on it.

### 0.3.5 (2019-08-14)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.3.4...v0.3.5)

* Bug fixes
  * Requiring `ezlog/rspec` in the `spec_helper` correctly captures log messages produced during tests. Requiring
    `ezlog` (as was done in the previous version) fails to capture logs because it loads the gem before `Rails` is 
    defined so the Railtie doesn't get executed.

### 0.3.4 (2019-08-14)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.3.3...v0.3.4)

* Bug fixes
  * Ezlog is required when requiring `ezlog/rspec`. This way all dependencies are in place even if `Bundler.require` 
    wasn't called.
  * Access log now correctly logs requests that fail with an uncaught error. Previously these requests were logged
    with a path of `/500`.

### 0.3.3 (2019-08-10)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.3.2...v0.3.3)

* Features & enhancements
  * [Sidekiq](https://github.com/mperham/sidekiq) logging respects the log level configured for the application.
  * Log level can be set from an environment variable (LOG_LEVEL).

### 0.3.2 (2019-06-18)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.3.1...v0.3.2)

* Features & enhancements
  * Ruby 2.4 is supported

* Bug fixes
  * Default log level is now set for the root logger instead of the root log layout so that the log level can be 
    overriden programatically per logger (if necessary) 

### 0.3.1 (2019-06-09)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.2.2...v0.3.1)

* Features & enhancements
  * Unified access log for [Rails](https://rubyonrails.org/)
    * 1 message per request
    * Includes request ID, parameters, response code
  * Non-verbose logging of uncaught exceptions in [Rails](https://rubyonrails.org/) apps
    * 1 message per error
    * Use ERROR level instead of FATAL
  * [Rack::Timeout](https://github.com/heroku/rack-timeout) logging is now completely turned off, because Timeout errors 
    are handled by the application's error logger and we don't want duplicated log messages 

* Bug fixes
  * Fix bug where the application log level wasn't set to INFO by default but remained on DEBUG

### 0.2.2 (2019-05-19)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.2.1...v0.2.2)

* Features & enhancements
  * [Sidekiq](https://github.com/mperham/sidekiq) error handler now logs the same job context as the JobLogger

### 0.2.1 (2019-05-17)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.2.0...v0.2.1)

* Features & enhancements
  * Provide logger creation mechanism so that projects don't explicitly depend on [Logging](https://github.com/TwP/logging)
  * Error handler for [Sidekiq](https://github.com/mperham/sidekiq) which logs the error in a single message (instead of 3 messages)
  * Add `run_count` to [Sidekiq](https://github.com/mperham/sidekiq) job log messages indicating how many times a job has run

* Bug fixes
  * Fix bug where exceptions without a backtrace would not get logged

### 0.2.0 (2019-05-12)

First version of the gem including the following:

* Features & enhancements
  * Use [Logging](https://github.com/TwP/logging) library for all logging
    * Includes logging layout for JSON logging to STDOUT
  * JobLogger for [Sidekiq](https://github.com/mperham/sidekiq)
  * Filter [Rack::Timeout](https://github.com/heroku/rack-timeout) logs to WARN level and above
  * [RSpec](https://rspec.info/) support
  * [Rails](https://rubyonrails.org/) integration via Railtie
