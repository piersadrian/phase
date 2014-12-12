require "commander"
require "phase/cli/all"

module Phase
  class CLI
    include ::Commander::Methods

    def run
      program :name, "Phase"
      program :version, ::Phase::VERSION
      program :description, "Phase controller."

      run!
    end
  end
end
