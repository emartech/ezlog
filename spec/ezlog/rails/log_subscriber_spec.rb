RSpec.describe Ezlog::Rails::LogSubscriber do
  def listeners_for(event)
    ActiveSupport::Notifications.notifier.listeners_for event
  end

  describe '.detach' do
    subject(:detach) { Ezlog::Rails::LogSubscriber.detach ActionController::LogSubscriber }
    after { ActionController::LogSubscriber.attach_to :action_controller }

    ActionController::LogSubscriber.new.public_methods(false).each do |event|
      next if event === :logger # TODO: why is it initially 0?
      it "removes subscribers of the given class from all #{event} events" do
        expect { detach }.to change { listeners_for("#{event}.action_controller").count }.from(1).to(0)
      end
    end
  end

  describe '.attach' do
    subject(:attach) { Ezlog::Rails::LogSubscriber.attach Ezlog::Rails::ActiveRecord::LogSubscriber, :active_record }
    after { Ezlog::Rails::LogSubscriber.detach Ezlog::Rails::ActiveRecord::LogSubscriber }

    it "attaches the subscriber to the given namespace" do
      expect { attach }.to change { listeners_for("sql.active_record").count }.by(1)
    end
  end
end
