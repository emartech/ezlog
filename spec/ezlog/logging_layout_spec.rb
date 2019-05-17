RSpec.describe Ezlog::LoggingLayout do
  let(:layout) { described_class.new(context) }
  let(:context) { {} }

  let(:message) { 'Hello, World!' }
  let(:logger_name) { 'TestLogger' }
  let(:level_name) { Logging::LEVELS.keys.sample }
  let(:event) { Logging::LogEvent.new(logger_name, Logging::LEVELS[level_name], message, false) }

  define :json_include do
    match { expect(JSON.parse(actual)).to include expected }
  end

  before(:all) { ::Logging.init unless ::Logging.initialized? }

  describe '#format' do
    subject(:format) { layout.format(event) }

    it { is_expected.to json_include 'timestamp' => event.time.iso8601 }
    it { is_expected.to json_include 'level' => level_name.upcase }
    it { is_expected.to json_include 'logger' => logger_name }
    it { is_expected.to json_include 'hostname' => Socket.gethostname }
    it { is_expected.to json_include 'pid' => Process.pid }
    it { is_expected.to match(/\n$/) }

    context 'when message context is given upon creation' do
      let(:context) { {environment: 'test'} }

      it { is_expected.to json_include 'environment' => 'test' }

      context 'when some part of the context is also present in the message' do
        let(:message) { {environment: 'demo'} }

        it { is_expected.to json_include 'environment' => 'demo' }
      end
    end

    context 'when message is a string' do
      let(:message) { 'log message' }

      it { is_expected.to json_include 'message' => message }
    end

    context 'when message is an array' do
      let(:message) { [1, 2, 3, 4] }

      it { is_expected.to json_include 'message' => message }
    end

    context 'when message is an exception' do
      let(:message) { StandardError.new('some error') }
      let(:backtrace) { [] }
      before { message.set_backtrace(backtrace) }

      it { is_expected.to json_include 'error' => {'class' => message.class.to_s, 'message' => message.message, 'backtrace' => message.backtrace} }
      it { is_expected.to json_include 'message' => message.message }

      context 'when the exception has no backtrace' do
        let(:backtrace) { nil }

        it 'does not fail' do
          expect { format }.not_to raise_error
        end
      end

      context 'when the exception has a long backtrace' do
        let(:backtrace) { 1.upto(25).map { |counter| "*line##{counter}*" } }

        it 'only includes the first 20 lines of the backtrace' do
          backtrace.first(20).each { |backtrace_line| expect(format).to include backtrace_line }
          backtrace.last(5).each { |backtrace_line| expect(format).not_to include backtrace_line }
        end
      end
    end

    context 'when Logging context is set' do
      before do
        Logging.mdc['X-Session'] = '123abc'
        Logging.mdc['Cookie'] = 'monster'
      end
      after { Logging.mdc.clear }

      it { is_expected.to json_include Logging.mdc.context }

      context 'when some part of the context is also present in the message' do
        let(:message) { {'X-Session' => 'qwe456'} }

        it { is_expected.to json_include 'X-Session' => 'qwe456' }
      end
    end
  end
end
