module Ezlog
  module RSpec
    module Helpers
      def log_output_is_expected
        expect(log_output)
      end

      def log_output
        @log_output.clone.readlines
      end
    end
  end
end
