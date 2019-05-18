module Ezlog
  module Sidekiq
    class JobContext
      class << self
        def from_job_hash(job_hash)
          basic_info_from(job_hash).merge named_arguments_from(job_hash)
        end

        private

        def basic_info_from(job)
          {
            jid: job['jid'],
            queue: job['queue'],
            worker: job['class'],
            created_at: job['created_at'],
            enqueued_at: job['enqueued_at'],
            run_count: (job['retry_count'] || -1) + 2
          }
        end

        def named_arguments_from(job)
          {}.tap do |arguments|
            method_parameters_of(job).each_with_index do |(_, param_name), index|
              arguments[param_name] = job['args'][index]
            end
          end
        end

        def method_parameters_of(job)
          Kernel.const_get(job['class'].to_sym).instance_method(:perform).parameters
        end
      end
    end
  end
end
