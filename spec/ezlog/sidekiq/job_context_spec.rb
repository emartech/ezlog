RSpec.describe Ezlog::Sidekiq::JobContext do
  include_context 'Sidekiq'

  describe '.from_job_hash' do
    subject(:job_message) { Ezlog::Sidekiq::JobContext.from_job_hash job_hash }
    let(:job_hash) do
      sidekiq_job_hash jid: 'job ID',
                       queue: 'job queue',
                       worker: 'TestWorker',
                       args: [1, 'name param'],
                       created_at: now,
                       enqueued_at: now
    end
    let(:now) { Time.now }

    it 'contains all relevant information about the job, including its parameters by name' do
      expect(job_message).to include jid: 'job ID',
                                     queue: 'job queue',
                                     worker: 'TestWorker',
                                     customer_id: 1,
                                     name: 'name param',
                                     created_at: now,
                                     enqueued_at: now
    end

    it 'contains the number of times this job has run (including the current execution)' do
      expect(job_message).to include run_count: 1
    end

    context 'when the job has already been run before' do
      before { job_hash['retry_count'] = 0 }

      it { is_expected.to include run_count: 2 }
    end

    context 'when the job was wrapped in an ActiveJob' do
      before do
        job_hash.merge! 'class' => 'ActiveJob',
                        'wrapped' => 'TestWorker'
      end

      it 'contains the wrapped job class' do
        expect(job_message).to include worker: 'TestWorker'
      end
    end

    context 'when the job is part of a batch' do
      before { job_hash['bid'] = 'aBatchId' }

      it 'contains the batch id' do
        expect(job_message).to include bid: 'aBatchId'
      end
    end

    context 'when the job has tags' do
      before { job_hash['tags'] = %w[a-tag b-tag] }

      it 'contains the batch id' do
        expect(job_message).to include tags: %w[a-tag b-tag]
      end
    end

    context "when Sidekiq's thread id of is set on the current thread" do
      before { Thread.current['sidekiq_tid'] = '[the thread id]' }

      it 'contains the thread id of the worker' do
        expect(job_message).to include tid: '[the thread id]'
      end
    end

    context "when Sidekiq's thread id is not set on the current thread" do
      before { Thread.current['sidekiq_tid'] = nil }

      it 'calculates a thread id' do
        expect(job_message).to include tid: (Thread.current.object_id ^ ::Process.pid).to_s(36)
      end
    end

    context 'when the job hash is empty' do
      let(:job_hash) { nil }

      it 'returns an empty Hash' do
        expect(job_message).to eq({})
      end
    end
  end
end
