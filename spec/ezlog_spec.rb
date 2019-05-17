RSpec.describe Ezlog do
  it "has a version number" do
    expect(Ezlog::VERSION).not_to be nil
  end

  describe '.logger' do
    subject(:logger) { Ezlog.logger 'TestLogger' }

    it 'returns a Logging logger with the specified name' do
      expect(logger).to be_a Logging::Logger
      expect(logger.name).to eq 'TestLogger'
    end
  end
end
