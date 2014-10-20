module Exos
  module Commands
    class Mosh < SSH
      def run
        options.default conn: "mosh"
        super
      end
    end
  end
end
