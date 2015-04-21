module Phase
  module CLI
    class Command
      include ::Phase::Util::Console

      class << self
        include ::Commander::Methods
      end

      attr_reader :args, :options

      def initialize(args, options)
        @args = args
        @options = options
      end

    end
  end
end
