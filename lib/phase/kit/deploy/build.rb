module Phase
  module Deploy

    class Build
      include ::Phase::Util::Shell

      attr_reader :build_dir, :clean_build, :version_tag

      def initialize(version_tag, options = {})
        @clean_build = options.fetch(:clean_build, true)
        @version_tag = version_tag

        if clean_build
          @build_dir = ::Pathname.new( options.fetch(:build_dir, "build") )
        else
          @build_dir = ::Pathname.new(".")
        end
      end

      def execute!
        prepare_environment
        build_assets
        commit_new_version!
        build_image
        push
      end

      private

        def build_assets
          precompile_assets
          sync_assets
        end

        def build_image
          prepare_clean_build if clean_build

          shell("docker build -t #{docker_repo}:#{version_tag} #{build_dir}") do |status|
            fail "Couldn't build Docker image"
          end
        end

        def commit_new_version!
          ::Phase::Deploy::Version.update(version_tag)
          shell("git add -f public/assets/*manifest* #{::Phase.config.deploy.version_lockfile}", allow_failure: true)
          shell("git commit -m 'Built v#{version_tag}'", allow_failure: true)
        end

        def prepare_environment
          raise_on_dirty_index!

          shell("docker ps > /dev/null 2>&1") do |status|
            fail <<-EOS.strip_heredoc
              Docker isn't responding. Is docker-machine running? Try:
                  docker-machine start dev && eval $(docker-machine env dev)
            EOS
          end

          pull_latest_build
        end

        def clone_local_git_repo
          current_branch = `git rev-parse --abbrev-ref HEAD`.strip
          shell("git clone --reference $(pwd) --branch #{current_branch} -- file://$(pwd) #{build_dir}") do |status|
            fail "Couldn't clone local copy of git repository"
          end
        end

        def docker_repo
          ::Phase.config.deploy.docker_repository
        end

        # FIXME: This approach isn't ideal because it compiles assets in the *working* git
        # directory rather than building in a clean, committed environment. This could lead
        # to errors in the compiled assets.
        def precompile_assets
          shell("RAILS_GROUPS=assets RAILS_ENV=production rake assets:precompile") do |status|
            fail "Couldn't precompile assets"
          end
        end

        def prepare_clean_build
          remove_stale_build_dir!
          clone_local_git_repo
        end

        # This needs to run *before* the version gets updated so we know which version
        # number to pull from the registry.
        def pull_latest_build
          shell("docker pull #{docker_repo}:#{::Phase::Deploy::Version.current}", allow_failure: true)
        end

        def push
          shell("docker push #{docker_repo}:#{version_tag}") do |status|
            fail "Couldn't push #{docker_repo}:#{version_tag}"
          end
        end

        def raise_on_dirty_index!
          shell('git diff-index --quiet --cached HEAD') do |status|
            fail "Other changes are already staged. Commit or stash them first"
          end
        end

        def remove_stale_build_dir!
          ::FileUtils.rm_rf(build_dir)
        end

        def sync_assets
          bucket = ::Phase.config.deploy.asset_bucket
          return log("Set `deploy.asset_bucket` in Phasefile to enable asset syncing") if bucket.blank?

          shell("RAILS_GROUPS=assets FOG_DIRECTORY=#{bucket} rake assets:sync") do |status|
            fail "Couldn't sync assets to The Clouds"
          end
        end
    end

  end
end
