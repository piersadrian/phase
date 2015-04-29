module Phase
  module Deploy

    class Deployment
      attr_reader :environment, :build

      def initialize(environment, options = {})
        @environment = environment
        @build = Build.new(options[:version_tag])
      end

      def execute!
        @build.execute
        deploy_image
      end
    end


    class SandboxDeployment < Deployment
      def initialize(options = {})
        @build = SandboxBuild.new(options[:version_tag])
      end
    end

  end
end
