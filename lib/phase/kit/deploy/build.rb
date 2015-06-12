module Phase
  module Deploy

    class Build
      include ::Phase::Util::Shell

      attr_reader :build_dir, :clean, :version_tag

      def initialize(version_tag, options = {})
        @clean       = options.fetch(:clean, true)
        @version_tag = version_tag

        if clean
          @build_dir = ::Pathname.new( options.fetch(:build_dir, "build") )
        else
          @build_dir = ::Pathname.new(".")
        end
      end

      def execute!
        check_environment
        build_image
        # tag_image
        push
      end

      private

        def build_image
          prepare_clean_build if clean

          shell("docker build -t #{repo_name}:#{version_tag} #{build_dir}") do |status|
            fail "Couldn't build Docker image"
          end
        end

        def check_environment
          shell("docker ps > /dev/null 2>&1") do |status|
            fail <<-EOS.strip_heredoc
              Docker isn't responding. Is boot2docker running? Try:
                  boot2docker start && $(boot2docker shellinit)
            EOS
          end
        end

        def clone_local_git_repo
          current_branch = `git rev-parse --abbrev-ref HEAD`.strip
          shell("git clone --reference $(pwd) --branch #{current_branch} -- file://$(pwd) #{build_dir}") do |status|
            fail "Couldn't clone local copy of git repository"
          end
        end

        def last_committed_mtime_for_file(file_path)
          rev_hash = `git rev-list HEAD "#{file_path}" | head -n 1`.chomp
          time_str = `git show --pretty=format:%ai --abbrev-commit #{rev_hash} | head -n 1`.chomp
          ::DateTime.parse(time_str).to_time
        end

        def prepare_clean_build
          remove_stale_build_dir!
          clone_local_git_repo
          set_file_modification_timestamps
        end

        def push
          shell("docker push #{repo_name}:#{version_tag}") do |status|
            fail "Couldn't push #{repo_name}:#{version_tag}"
          end
        end

        def remove_stale_build_dir!
          ::FileUtils.rm_rf(build_dir)
        end

        def repo_name
          ::Phase.config.deploy.docker_repository
        end

        def set_file_modification_timestamps
          log "Preparing docker cache..."

          queue = ::Queue.new

          ::FileUtils.cd(build_dir) do
            # Sets consistent mtime on directories because docker cares about that
            system("find . -type d | xargs touch -t 7805200000")

            files = `git ls-files`.split
            files.each { |f| queue.push(f) }

            bar = ::ProgressBar.new("Setting mtimes", files.count)

            threads = 4.times.map do |idx|
              ::Thread.new do
                begin
                  while path = queue.pop(true)
                    ::FileUtils.touch(path, mtime: last_committed_mtime_for_file(path))
                    bar.inc
                  end
                rescue ThreadError
                end
              end
            end

            threads.each(&:join)
            bar.finish
          end
        end
    end

  end
end
