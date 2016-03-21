module Phase
  module CLI
    class Build < Command

      command :build do |c|
        c.syntax = "phase build [-s]"

        c.option "-s", "--sandbox", String, "Build in sandbox mode: uses current directory's possibly dirty git tree as build context."
        c.option "-n", "--version-number", String, "Build number to create."

        c.description = <<-EOS.strip_heredoc
          Builds a new Docker image of the latest committed code on the current branch. Tags the
          build with <version_number>.
        EOS

        c.action do |args, options|
          options.default(sandbox: false)
          new(args, options).run
        end
      end

      attr_reader :clean_build, :version_number

      def initialize(args, options)
        super
        @clean_build = !options.sandbox
        @version_number = options.version_number
      end

      def run
        build = ::Phase::Deploy::Build.new(version_number, clean_build: clean_build)
        build.execute!
      end

      private

        def version_number
          @version_number ||= get_next_version_number
        end

        def get_next_version_number
          current_version = ::Phase::Deploy::Version.current

          log "Last release was version #{ current_version.magenta }." if current_version

          input = ask "New version number:"
          fail "Version number is required" if input.blank?
          input
        end

    end
  end
end
