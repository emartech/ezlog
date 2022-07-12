### 0.10.5 (2022-07-06)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.10.4...v0.10.5)

* Fix
  * Fix a bug introduced in yanked version 0.10.4 where workers would fail to start
    with an `undefined method: prepare` message on newer versions of Sidekiq
  * Remove support for "job-specifc log level" feature in Sidekiq
  * Fixed a bug which could result in an `undefined method 'info'` error message.

### 0.10.4 (2022-07-06), yanked

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.10.3...v0.10.4)

* Fix
  * Removed support for "job-specific log level" feature in Sidekiq.
  * Fixed the bug which could result in an `undefined method 'info'` error message.

### 0.10.3 (2022-06-29)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.10.2...v0.10.3)

* Fix
  * Fixed a bug where `Sidekiq::Logger` was potentially initialized too many times,
    which could result in an `undefined method 'info'` error message.

### 0.10.2 (2022-06-29)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.10.1...v0.10.2)

* Features & enhancements
  * Sidekiq 6.5 compatibility
  
### 0.10.1 (2022-01-22)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.10.0...v0.10.1)

* Fix
  * Fixed a bug where `ActionView::LogSubscriber` was potentially not (eager)loaded by the time we tried to detach it.
    With this fix Rails 6.1 running on Ruby 3 should be fully supported.

### 0.10.0 (2021-07-01)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.6...v0.10.0)

* Features & enhancements
  * Do not log exceptions which are handled by Rails. Therefore you can't get false alarms from your exception notifier

### 0.9.6 (2021-06-30)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.5...v0.9.6)

* Fix
  * fixing a Rails 6.1 specific issue with ActiveRecord array parameter in a query (`User.where(id: [1,2,3,4])`)

### 0.9.5 (2020-10-01)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.4...v0.9.5)

* Fix
  * fixing an issue with the Sidekiq job's log context generation:
    using a namespaced Sidekiq worker (`SomeModule::SomeWorker`) cause the log context generations to fail with: `NameError: wrong constant name SomeModule::SomeWorker`

### 0.9.4 (2020-09-26)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.3...v0.9.4)

* Features & enhancements
  * added Ruby 2.7 to the list of version CI will test the code with
  * remove dot-files and Rakefile from the gem
* Fix
  * stop using `Hash#merge` with multiple arguments as it's only supported from Ruby 2.6

### 0.9.3 (2020-09-20)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.2...v0.9.3)

* Features & enhancements 
    * Switching to [Oj](https://github.com/ohler55/oj) for fast JSON serialization
    * Allow level to be formatted (so it can be logged as a number too)
    
        if you want to use Ougai-like numbers you can do something like this: 
        ```ruby
        config.ezlog.layout_options = { level_formatter: ->(level_number) { (level_number + 2) * 10 } } 
        
        Rails.logger.error('Boom!')
        #=> {"logger":"Application","timestamp":"2020-09-20T19:29:03+02:00","level":50,"hostname":"BUD010256.local","pid":19872,"message":"Boom!"}
        ``` 
    * initial context (a context which will be added to every single line of log) can be configured via `config.ezlog.layout_options` and it defaults to `{environment: ::Rails.env}`
    
### 0.9.2 (2020-09-19)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.1...v0.9.2)

* Features & enhancements 
  * Improvements of the [Sidekiq](https://github.com/mperham/sidekiq) integration
    * supports additional job information: batch id, tags and thread id (bid, tags, tid)
    * support logging "death" events (setting up a death_handler) 

### 0.9.1 (2020-05-10)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.9.0...v0.9.1)

* Bug fixed
  * Fixed a bug in access log exclusion pattern matching that would exclude partial matches for a path if it was 
    specified as a string (expecting to be excluded only in case of a full match).

### 0.9.0 (2020-05-10)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.8.0...v0.9.0)

* Features & enhancements
  * Ezlog now supports [Rails](https://rubyonrails.org/) 6.
  * Added the ability to exclude certain paths from access logging. Use the `exclude_paths` configuration option to
    add paths (strings or regexps) to exclude from your access logs.

### 0.8.0 (2020-04-07)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.7.1...v0.8.0)

* Bug fixes
  * Reverted the change introduced in `v0.5.2` which extended the [Sidekiq](https://github.com/mperham/sidekiq) logger
    interface because it caused problems with other third-party integrations
    (e.g. [sidekiq-unique-jobs](https://github.com/mhenrixon/sidekiq-unique-jobs)).
    [Sidekiq](https://github.com/mperham/sidekiq) itself removed this interface element in `v6.0.1`, so the current
    change breaks compatibility with [Sidekiq](https://github.com/mperham/sidekiq) `v6.0.0` exclusively. If you're
    using that version, please upgrade.

### 0.7.1 (2020-03-12)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.7.0...v0.7.1)

* Bug fixes
  * Fixed a bug in the [Sidekiq](https://github.com/mperham/sidekiq) error handler which caused the error handler
    to throw an additional error if there was no job hash in the original error context.

### 0.7.0 (2020-03-11)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.6.0...v0.7.0)

* Features & enhancements
  * Added the ability to configure parameter logging of the [Rails](https://rubyonrails.org/) access log.
    By default, all parameters are logged under the key `params`. By turning on the `log_only_whitelisted_params`
    config swith, you can make sure that only the parameters whose name is included in the `whitelisted_params`
    config setting get logged under the `params` key. All parameters will still be logged, but serialized into a
    single string under the `params_seralized` key, not creating a lot of noise under `params`.

### 0.6.0 (2019-11-29)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.5.3...v0.6.0)

* Features & enhancements
  * Disabled [Sequel](https://sequel.jeremyevans.net/) logging by default. It can be enabled with the
    `enable_sequel_logging` config switch.

### 0.5.3 (2019-10-29)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.5.2...v0.5.3)

* Features & enhancements
  * Added support for the new "job-specific log level" feature in [Sidekiq 6.0.1](https://github.com/mperham/sidekiq)

### 0.5.2 (2019-09-27)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.5.1...v0.5.2)

* Bug fixes
  * [Sidekiq](https://github.com/mperham/sidekiq) logger now supports the [Sidekiq 6](https://github.com/mperham/sidekiq) 
    logger interface which includes the method `with_context`. This is important because other gems 
    (notably [sidekiq-unique-jobs](https://github.com/mhenrixon/sidekiq-unique-jobs)) depend on this method 
    and might break if it's not present.

### 0.5.1 (2019-09-16)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.5.0...v0.5.1)

* Bug fixes
  * Projects that don't use ActiveRecord can still use Ezlog. The previous version tried to replace ActiveRecord's
    log subscriber even when ActiveRecord wasn't used and thus halted the initialization process.

### 0.5.0 (2019-09-11)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.4.0...v0.5.0)

* Features & enhancements
  * Support [Sidekiq 6](https://github.com/mperham/sidekiq) logging
  * Log the underlying (real) job class when using [Sidekiq](https://github.com/mperham/sidekiq) wrapped into
    [Active Job](https://github.com/rails/rails/tree/master/activejob)


### 0.4.0 (2019-09-06)

[Full Changelog](https://github.com/emartech/ezlog/compare/v0.3.5...v0.4.0)

* Features & enhancements
  * Added log context management methods `within_log_context` and `add_to_log_context` to Ezlog module.
  * Replaced ActiveRecord query logging with a log subscriber that logs queries via Ezlog.
  * Added automatic query logging (at DEBUG level) to [Sequel](https://sequel.jeremyevans.net/) connections.
  
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
