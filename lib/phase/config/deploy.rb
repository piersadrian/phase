module Phase
  module Config
    class Deploy

      # @return [Array<Environment>] the configured deployment environments
      attr_reader :environments


      # @return [String] the compact or fully-qualified address of the Docker repository
      # @example Sample settings
      #   config.deploy.docker_repository = "mycompany/myrepo"
      #   config.deploy.docker_repository = "https://docker.mycompany.com/myrepo"
      attr_accessor :docker_repository


      def initialize
        @environments = []
      end

      # Adds a new deployment environment.
      # @return [Environment] the new environment
      def environment(name, options = {})
        @environments << Environment.new(name, options)
      end
    end


    class Environment

      attr_accessor :name, :perform_build, :server_filters

      alias_method :perform_build?, :perform_build

      def initialize(name, options = {})
        @name = name
        @perform_build = options.fetch(:build, true)
        @server_filters = options.fetch(:servers, {})
      end

    end
  end
end
