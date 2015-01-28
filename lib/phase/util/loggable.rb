module Phase
  module Util
    module Loggable

      def log(str)
        puts "[phase]".green + " #{ str }"
      end

      def fail(str)
        abort "[phase]".red + " #{ str }"
      end

    end
  end
end
