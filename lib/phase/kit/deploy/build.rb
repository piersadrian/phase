module Phase
  module Deploy

    class Build
      attr_reader :version_tag, :build_dir

      def initialize(version_tag, options = {})
        @version_tag = version_tag
        @build_dir = options.fetch(:build_dir, "./build")
      end

      def execute
        build_image
        tag_image
        push
      end

      private

        def build_image
          clear_build_dir
          clone_local_repo
          system("docker build -t #{repo_name}:#{version_tag} #{build_dir}")
        end

        def clear_build_dir
          ::FileUtils.mkdir_p(build_dir)
        end

        def clone_local_repo
          system("git clone --depth 1 -- file://$(pwd) #{build_dir}")
        end

        def tag_image
          system("docker tag #{repo_name}:#{version_tag} #{repo_name}:latest")
        end

        def push
          system("docker push #{repo_name}:#{version_tag}")
          system("docker push #{repo_name}:latest")
        end

        def repo_name
          ::Phase.config.deploy.docker_repository
        end
    end


    class SandboxBuild < Build
      def execute
        build_image
        push
      end

      private

        def build_image
          system("docker build -t #{repo_name}:#{version_tag} .")
        end

        def push
          system("docker push #{repo_name}:#{version_tag}")
        end
    end

  end
end
