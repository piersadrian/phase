require "commander"
require "terminal-table"
require "colorize"
require "fog"

require "cloud/version"

require "cloud/commands"
require "cloud/commands/status"
require "cloud/commands/ssh"
require "cloud/commands/keys"

module Cloud
  class Application
    include ::Commander::Methods

    def run
      program :name, "Cloud"
      program :version, ::Cloud::VERSION
      program :description, "Cloud controller."

      run!
    end
  end
end
