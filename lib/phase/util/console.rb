module Phase
  module Util
    module Console

      def log(str)
        puts "[phase]".green + " #{ str }"
      end

      def fail(str)
        puts
        abort "[phase]".red + " #{ str }"
      end

    end
  end
end
