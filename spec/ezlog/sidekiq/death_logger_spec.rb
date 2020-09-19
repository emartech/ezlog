RSpec.describe Ezlog::Sidekiq::DeathLogger do
  include_context 'Sidekiq'

  let(:logger) { Ezlog::Sidekiq::DeathLogger.new }

  describe '#call' do
    subject(:call) { logger.call job, error }

    let(:error) { StandardError.new 'error message' }
    let(:job) { sidekiq_job_hash(jid: 'job ID') }

    it 'logs the error in a single message at ERROR level' do
      expect { call }.to log(message: 'error message').at_level(:error)
    end

    it 'logs the job context' do
      expect { call }.to log jid: 'job ID'
    end
  end
end
