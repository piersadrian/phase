module Exos
  module Commands
    class Logs < Command

      command :logs do |c|
        c.syntax = "exos logs [--tail]"

        c.option "-t", "--tail", "Stream logs."

        c.description = "."
        c.action do |args, options|
          new(args, options).run
        end
      end

      def run
      end

    end
  end
end
