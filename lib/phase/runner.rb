module Phase
  class Runner

    def on_role(role_name, options = {}, &block)
      hosts = []
      on(hosts, options, &block)
    end

    def on(hosts, options={}, &block)
      # subset = Configuration.env.filter hosts
      SSHKit::Coordinator.new(hosts).each(options, &block)
    end

    def run_locally(&block)
      SSHKit::Backend::Local.new(&block).run
    end

  end
end
