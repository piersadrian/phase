require "terminal-table"
require "active_support"
require "progressbar"
require "colorize"
require "fog"
require "sshkit"

require "dotenv"
::Dotenv.load if defined?(::Dotenv)

require "phase/version"
require "phase/configuration"
require "phase/backend"
require "phase/command"
require "phase/runner"

module Phase
  class << self

    def config
      @@config ||= Configuration.new
    end

    def reset_config!
      @@config = Configuration.new
    end

  end

  reset_config!
end
