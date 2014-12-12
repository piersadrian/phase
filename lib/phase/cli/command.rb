module Phase
  module CLI
    class Command

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
