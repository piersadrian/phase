module Phase
  module CLI
    class Build < Command

      command :build do |c|
        c.syntax = "phase build <version_number>"

        c.description = <<-EOS.strip_heredoc
          Builds a new Docker image of the latest committed code on the current branch. Tags the
          build with <version_number>.
        EOS

        c.action do |args, options|
          new(args, options).run
        end
      end

      attr_reader :version_number

      def initialize(args, options)
        super

        @version_number = args[0]

        fail "must specify version number" unless version_number
      end

      def run
        build = ::Phase::Deploy::Build.new(version_number)
        build.execute!
      end

    end
  end
end
