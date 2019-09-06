RSpec.describe Ezlog do
  it "has a version number" do
    expect(Ezlog::VERSION).not_to be nil
  end

  let(:logger) { Ezlog.logger 'TestLogger' }

  describe '.logger' do
    it 'returns a Logging logger with the specified name' do
      expect(logger).to be_a Logging::Logger
      expect(logger.name).to eq 'TestLogger'
    end
  end

  describe '.add_to_log_context' do
    after { Logging.mdc.clear }

    it 'adds the specified params to the current log context' do
      Ezlog.add_to_log_context test: 'message'
      expect { logger.info 'test' }.to log message: 'test', test: 'message'
    end
  end

  describe '.within_log_context' do
    it 'runs the passed block within the specified log context' do
      Ezlog.within_log_context test: 'message' do
        logger.info 'test1'
      end
      logger.info 'test2'

      expect(log_output).to include_log_message message: 'test1', test: 'message'
      expect(log_output).to include_log_message message: 'test2'
      expect(log_output).not_to include_log_message message: 'test2', test: 'message'
    end
  end
end
