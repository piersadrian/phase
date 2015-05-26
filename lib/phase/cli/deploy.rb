module Phase
  module CLI
    class Deploy < Command

      command :deploy do |c|
        c.syntax = "phase deploy <environment_name> <version_number>"

        c.description = <<-EOS.strip_heredoc
          Builds and deploys code to the specified <environment_name>, which may be
          any environment configured in the Phasefile.
        EOS

        c.action do |args, options|
          new(args, options).run
        end
      end

      attr_reader :env_name, :version_number

      def initialize(args, options)
        super

        fail "must specify both environment and version number" unless args.count >= 2

        @env_name       = args[0]
        @version_number = args[1]

        fail "must specify environment"    unless env_name
        fail "must specify version number" unless version_number
      end

      def run
        environment = config.deploy.environments.find { |e| e.name == env_name }
        fail "unknown environment: '#{env_name}'" unless environment

        deployment = Deploy::Deployment.new(environment, version_tag: version_number)
        deployment.execute!
      end

    end
  end
end
