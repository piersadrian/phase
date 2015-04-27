module Phase
  module Deploy
    class Deployment

      # environment
      # build options
        # tag strategy
      # server options
        # environment name
        # role name

      attr_reader :build

      def initialize(environment, options = {})
        case environment
        when :sandbox
          self.build = SandboxBuild.new
        else
          self.build = Build.new
        end


      end
    end
  end
end
