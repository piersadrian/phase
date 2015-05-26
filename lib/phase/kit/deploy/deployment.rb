module Phase
  module Deploy

    class Deployment
      attr_reader :options#, :build

      def initialize(options = {})
        @options = options
      end

      # def build
      #   @build ||= Build.new(options[:version_tag])
      # end

      def execute!
        # build.execute!
        deploy_image
      end

      private

        def deploy_image
          system("echo yaaaay")
        end
    end

  end
end
