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

    context 'when the query has parameters' do
      let(:event) do
        instance_double ActiveSupport::Notifications::Event,
                        payload: {
                          name: 'User Load',
                          sql: 'SELECT * FROM users LIMIT $1',
                          binds: [instance_double(ActiveRecord::Relation::QueryAttribute, name: 'LIMIT', value: 1)],
                          type_casted_binds: [1],
                          type: instance_double(ActiveModel::Type::Value, binary?: false)
                        },
                        duration: 1.235
      end

      it 'logs the query parameters' do
        expect { trigger_event }.to log(params: {LIMIT: 1}).at_level(:debug)
      end

      xcontext 'when there are binary parameters' do
        let(:event) do
          instance_double ActiveSupport::Notifications::Event,
                          payload: {
                            name: 'User Load',
                            sql: 'SELECT * FROM users WHERE bytecode = $1',
                            binds: [instance_double(ActiveRecord::Relation::QueryAttribute, name: 'bytecode', value: 'some binary value')],
                            type_casted_binds: ['some binary value'],
                            type: instance_double(ActiveModel::Type::Value, binary?: true)
                          },
                          duration: 1.235
        end

        it "doesn't log the binary parameter's value" do
          expect { trigger_event }.to log(bytecode: '<binary data>').at_level(:debug)
        end
      end
    end
  end
end
