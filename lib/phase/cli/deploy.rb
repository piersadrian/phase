module Phase
  module CLI
    class Deploy < Command

      command :deploy do |c|
        c.syntax = "phase deploy <environment>"

        c.description = <<-EOS.strip_heredoc
          Builds and deploys code to the specified <environment>. <environment> may be
          any environment configured in the Phasefile.
        EOS

        c.action do |args, options|
          new(args, options).run
        end
      end

      attr_reader :environment

      def initialize(args, options)
        @environment = args.first
        super
      end

      def run
        if environment == "sandbox"
          deployment = ::Phase::Deploy::SandboxDeployment.new
        else
          deployment = ::Phase::Deploy::Deployment.new(environment)
        end

        deployment.execute!
      end

    end
  end
end
