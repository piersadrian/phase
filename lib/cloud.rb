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

      # Exclude option flags.
      # if ARGV.first && !ARGV.first.match(/\A-/)
        # ::Cloud::Commands.named(ARGV.first).new
      # end

      # Commands.define_commands!

      # command :status do |c|
      #   c.syntax = "cloud status"
      #   c.description = "Prints the current status of configured VPCs, subnets, and EC2 instances."
      #   c.action do |args, options|
      #     ::Cloud::Commands::Status.new(args, options).run
      #   end
      # end
      #
      # command :status do |c|
      #   c.syntax = "cloud login NAME"
      #   c.description = "Prints the current status of configured VPCs, subnets, and EC2 instances."
      #   c.action do |args, options|
      #     ::Cloud::Commands::Status.new(args, options).run
      #   end
      # end

      run!
    end
  end
end
