RSpec.describe Ezlog::Rails::LogSubscriber do
  after { ActionController::LogSubscriber.attach_to :action_controller }

  def listeners_for(event)
    ActiveSupport::Notifications.notifier.listeners_for event
  end

  describe '.detach' do
    subject(:detach) { Ezlog::Rails::LogSubscriber.detach ActionController::LogSubscriber }

    ActionController::LogSubscriber.new.public_methods(false).each do |event|
      it "removes subscribers of the given class from all #{event} events" do
        expect { detach }.to change { listeners_for("#{event}.action_controller").count }.from(1).to(0)
      end
    end
  end
end
