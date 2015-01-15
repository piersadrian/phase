module Phase
  module Mixins
    module Loggable

      def log(str)
        out = "[phase]".green
        out << " #{ str }"
        puts out
      end

      def fail!(str)
        out = "[phase]".red
        out << " #{ str }"
        abort out
      end

    end
  end
end
