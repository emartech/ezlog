module Ezlog
  module Rails
    class LogSubscriber
      class << self
        def detach(subscriber_class)
          subscriber = ::ActiveSupport::LogSubscriber.log_subscribers.find { |subscriber| subscriber.is_a? subscriber_class }
          return unless subscriber

          subscriber.patterns.each do |(pattern,_)|
            ::ActiveSupport::Notifications.notifier.listeners_for(pattern).each do |listener|
              ::ActiveSupport::Notifications.unsubscribe listener if listener.instance_variable_get('@delegate').is_a? subscriber_class
            end
          end
        end

        def attach(subscriber_class, namespace)
          subscriber_class.attach_to namespace
        end
      end
    end
  end
end
