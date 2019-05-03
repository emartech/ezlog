require 'rspec/expectations'

RSpec::Matchers.define :log do
  supports_block_expectations
  chain :at_level, :log_level

  description do
    "should log #{formatted_expected_messages}"
  end

  failure_message do
    error_message = if log_level.nil?
                      "expected operation to log '#{formatted_expected_messages}'"
                    else
                      "expected operation to log '#{formatted_expected_messages}' at #{log_level_string(log_level)} level"
                    end
    "#{error_message}\n\nLog output:\n#{@log_output_array.join('')}"
  end

  match do |operation|
    raise 'log matcher only supports block expectations' unless operation.is_a? Proc
    operation.call
    @log_output_array = log_output.readlines
    @log_output_array.any? { |log_line| includes?(log_line, expected_messages) }
  end

  def formatted_expected_messages
    expected_messages.join(', ')
  end

  def expected_messages
    @expected_messages ||= extract_expected_messages_from(expected)
  end

  def extract_expected_messages_from(object)
    case object
    when Hash
      object.map { |k, v| MultiJson.dump(k => v)[1...-1] }
    when String
      [object]
    else
      raise NotImplementedError, 'log expectation must be Hash or String'
    end
  end

  def includes?(log_line, messages)
    return false unless includes_log_level?(log_line)
    messages.all? { |message| log_line.include?(message) }
  end

  def includes_log_level?(log_line)
    return true if log_level.nil?
    log_line.include?(log_level_string(log_level))
  end

  def log_level_string(log_level)
    return 'WARN' if log_level == :warning
    log_level.to_s.upcase
  end
end
