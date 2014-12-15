module Phase
  module SSH
    class Backend < ::SSHKit::Backend::Netssh
      include ::SSHKit::CommandHelper

      def initialize(*args)
        # BUG: Backend::Netssh doesn't assign @pool when subclassed.
        self.class.pool = ::SSHKit::Backend::ConnectionPool.new
        super
      end

      def on_remote_host(remote_host, &block)
        @remote_host = remote_host
        yield
      end

      private

        def command(*args)
          options = args.extract_options!
          SSH::Command.new(*[ *args, options.merge({
            in: @pwd.nil? ? nil : File.join(@pwd),
            env: @env,
            host: @host,
            user: @user,
            group: @group,
            remote_host: @remote_host
          }) ])
        end
    end
  end
end
