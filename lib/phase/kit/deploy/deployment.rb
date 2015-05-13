module Phase
  module Deploy

    class Deployment
      attr_reader :options, :build

      def initialize(options = {})
        @options = options
      end

      def build
        @build ||= Build.new(options[:version_tag])
      end

      def execute!
        build.execute!
        deploy_image
      end

      private

        def deploy_image
          system("")
        end
    end


    class SandboxDeployment < Deployment
      def build
        @build ||= SandboxBuild.new(options[:version_tag])
      end
    end


    class StagingDeployment < Deployment
    end


    class ProductionDeployment < Deployment
    end

  end
end
