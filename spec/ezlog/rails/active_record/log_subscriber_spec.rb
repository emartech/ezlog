require 'active_record'

RSpec.describe Ezlog::Rails::ActiveRecord::LogSubscriber do
  let(:event) do
    instance_double ActiveSupport::Notifications::Event,
                    payload: {
                      name: 'User Load',
                      sql: 'SELECT * FROM users'
                    },
                    duration: 1.235
  end

  before { allow(::ActiveRecord::Base).to receive(:logger).and_return Ezlog.logger('Application') }

  describe '#sql' do
    subject(:trigger_event) { described_class.new.sql event }

    it 'logs the SQL query execution event at DEBUG level' do
      expect { trigger_event }.to log(message: 'SQL - User Load (1.235ms)',
                                      sql: 'SELECT * FROM users',
                                      duration_sec: 0.00124).at_level(:debug)
    end
  end
end
