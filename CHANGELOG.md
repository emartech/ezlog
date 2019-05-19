### 0.2.2 (in development)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.2.1...master)

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
  * Rails integration via Railtie
