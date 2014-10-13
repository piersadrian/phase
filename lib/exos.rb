require "commander"
require "terminal-table"
require "colorize"
require "fog"

require "exos/version"

require "exos/commands"
require "exos/commands/status"
require "exos/commands/ssh"
require "exos/commands/keys"

module Exos
  class Application
    include ::Commander::Methods

    def run
      program :name, "Exos"
      program :version, ::Exos::VERSION
      program :description, "Exos controller."

      run!
    end
  end
end
