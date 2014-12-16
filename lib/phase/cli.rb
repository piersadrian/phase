require "commander"

module Phase
  module CLI
    class Application
      include ::Commander::Methods

      def run
        program :name, "Phase"
        program :version, ::Phase::VERSION
        program :description, "Phase controller."

        always_trace!

        run!
      end
    end
  end
end

require "phase/cli/all"
