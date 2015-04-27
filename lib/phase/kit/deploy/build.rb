module Phase
  module Deploy

    class Build
      attr_reader :version_tag

      def initialize(version_tag)
        @version_tag = version_tag
      end

      def execute
        build_image
        tag_latest_image
        push
      end

      private

        def build_image
          clear_build_dir
          clone_clean_repo
          system("docker build -t #{repo_name}:#{version_tag} .build/")
        end

        def tag_latest_image
          system("docker tag #{repo_name}:#{version_tag} #{repo_name}:latest")
        end

        def push
          system("docker push #{repo_name}:#{version_tag}")
        end

        def repo_name
          ::Phase.config.docker_repository
        end
    end


    class SandboxBuild < Build
      def build
        system(build_image_cmd)
      end
    end

  end
end
