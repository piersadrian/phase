module Phase
  module DSL

    def on_role(role_name, options = {}, &block)
      servers = ::Phase::Adapters::AWS::Server.where(role: role_name)
      on(servers.map {|s| s.resource.private_ip_address }, options, &block)
    end

    def on(destination_ips, options = {}, &block)
      server = ::Phase::Adapters::AWS::Server.where(role: ::Phase.config.bastion_role).first

      raise ArgumentError, "no servers found" unless server

      endpoint    = "#{ ::Phase.config.bastion_user }@#{ server.resource.dns_name }"
      coordinator = SSH::Coordinator.new(endpoint)

      Array(destination_ips).each do |ip|
        coordinator.each(options) do
          on_remote_host(ip) { instance_exec(&block) }
        end
      end

      true
    end

    def run_locally(&block)
      ::SSHKit::Backend::Local.new(&block).run
    end

  end
end

include ::Phase::DSL
