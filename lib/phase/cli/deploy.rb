module Phase
  module CLI
    class Deploy < Command

      command :deploy do |c|
        c.syntax = "phase deploy [-e environment_name] version_number"

        c.option "-e", "--env environment_name", String, "Deploy to this environment."

        c.description = <<-EOS.strip_heredoc
          Builds and deploys code to the specified 'environment_name'. 'environment_name' may be
          any environment configured in the Phasefile.
        EOS

        c.action do |args, options|
          new(args, options).run
        end
      end

      attr_reader :version_number

      def initialize(args, options)
        super

        @version_number = args.first

        fail "must specify environment with '-e'" unless options.env
        fail "must specify version number" unless version_number
      end

      def run
        opts = {
          version_tag: version_number
        }

        deployment = case options.env
        when "sandbox"
          ::Phase::Deploy::SandboxDeployment.new(opts)
        when "staging"
          ::Phase::Deploy::StagingDeployment.new(opts)
        when "production"
          ::Phase::Deploy::ProductionDeployment.new(opts)
        else
          fail "unknown environment: '#{environment}'"
        end

        deployment.execute!
      end

    end
  end
end
