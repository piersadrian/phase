module Phase
  module Deploy

    class Build
      include ::Phase::Util::Shell

      attr_reader :version_tag, :build_dir

      def initialize(version_tag, options = {})
        @version_tag = version_tag
        @build_dir = ::Pathname.new( options.fetch(:build_dir, "build") )
      end

      def execute!
        build_image
        # tag_image
        push
      end

      private

        def build_image
          remove_stale_build_dir
          clone_local_repo

          shell("docker build -t #{repo_name}:#{version_tag} #{build_dir}") do |status|
            fail "couldn't build Docker image"
          end
        end

        def remove_stale_build_dir
          ::FileUtils.rm_r(build_dir)
        end

        def clone_local_repo
          shell("git clone --depth 1 -- file://$(pwd) #{build_dir}") do |status|
            fail "couldn't clone local copy of git repository"
          end
        end

        # def tag_image
        #   shell("docker tag #{repo_name}:#{version_tag} #{repo_name}:latest") do |status|
        #     fail "couldn't tag Docker image"
        #   end
        # end

        def push
          shell("docker push #{repo_name}:#{version_tag}") do |status|
            fail "couldn't push #{repo_name}:#{version_tag}"
          end

          shell("docker push #{repo_name}:latest") do |status|
            fail "couldn't push #{repo_name}:latest"
          end
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
          shell("docker build -t #{repo_name}:#{version_tag} .") do |status|
            fail "couldn't build Docker image"
          end
        end

        def push
          shell("docker push #{repo_name}:#{version_tag}") do |status|
            fail "couldn't push #{repo_name}:#{version_tag}"
          end
        end
    end

  end
end
