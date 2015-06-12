module Phase
  module Util
    module Console

      # Prompts user for input.
      def ask(str)
        print "[phase] ".blue.on_cyan + "#{str}".black.on_cyan + " "
        STDIN.gets.chomp
      end

      # Prints a message.
      def log(str)
        puts "[phase]".green + " #{ str }"
      end

      # Prints a message and then exits.
      def fail(str)
        puts
        abort "[phase]".red + " #{ str }"
      end

    end
  end
end
