require 'active_support/all'
require 'capistrano'
require 'colorize'
require 'erb'
require 'fog'
require 'progressbar'
require 'sshkit'
require 'terminal-table'


require 'phase/adapter'
require 'phase/adapters/abstract'
require 'phase/adapters/aws'

require "phase/util/console"
require "phase/util/shell"

require 'phase/kit/deploy/build'
require 'phase/kit/deploy/deployment'

require 'phase/kit/ipa/app'
require 'phase/kit/ipa/enterprise_deployment'

require 'phase/kit/ssh/backend'
# require 'phase/kit/ssh/bastion'
require 'phase/kit/ssh/bastion_coordinator'
require 'phase/kit/ssh/command'
require 'phase/kit/ssh/runners'

require 'phase/configuration'
require 'phase/config/deploy'
require 'phase/config/ipa'

require 'phase/version'


module Phase
  class << self

    def config
      @@config ||= Configuration.new
    end

    def reset_config!
      @@config = nil
    end

    def configure(&block)
      yield config
    end

    def adapter
      config.adapter
    end

  end

  class ResourceNotFoundError < ::StandardError; end
end

Phase.config.load_phasefile!
