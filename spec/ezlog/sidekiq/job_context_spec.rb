RSpec.describe Ezlog::Sidekiq::JobContext do
  class TestWorker
    def perform(customer_id, name)
    end
  end

  describe '.from_job_hash' do
    subject(:job_message) { Ezlog::Sidekiq::JobContext.from_job_hash job_hash }
    let(:job_hash) do
      {
        'jid' => 'job id',
        'queue' => 'job queue',
        'class' => 'TestWorker',
        'args' => [1, 'name param'],
        'created_at' => now,
        'enqueued_at' => now
      }
    end
    let(:now) { Time.now }

    it 'contains all relevant information about the job' do
      expect(job_message).to include(jid: 'job id',
                                     queue: 'job queue',
                                     worker: 'TestWorker',
                                     customer_id: 1,
                                     name: 'name param',
                                     created_at: now,
                                     enqueued_at: now)
    end

    it 'contains the number of times this job has run (including the current execution)' do
      expect(job_message).to include run_count: 1
    end

    context 'when the job has already been run before' do
      before { job_hash['retry_count'] = 0 }

      it { is_expected.to include run_count: 2}
    end
  end
end
