require 'terminal-table'
require 'active_support'
require 'progressbar'
require 'colorize'
require 'fog'
require 'sshkit'

require 'dotenv'
::Dotenv.load if defined?(::Dotenv)

require 'phase/adapters/abstract'
require 'phase/adapters/aws'

require 'phase/ssh/backend'
require 'phase/ssh/command'
require 'phase/ssh/coordinator'

require 'phase/configuration'
require 'phase/version'


module Phase
  class << self

    def config
      @@config ||= Configuration.new
    end

    def reset_config!
      @@config = nil
    end

  end

  config
end
