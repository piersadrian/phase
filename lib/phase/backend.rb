module Phase
  class Backend < ::SSHKit::Backend::Netssh
    def initialize(*args)
      # BUG: Backend::Netssh doesn't assign @pool when subclassed.
      self.class.pool = ::SSHKit::Backend::ConnectionPool.new
      super
    end

    def command(*args)
      options = args.extract_options!
      ::Phase::Command.new(*[*args, options.merge({in: @pwd.nil? ? nil : File.join(@pwd), env: @env, host: @host, user: @user, group: @group})])
    end
  end
end
