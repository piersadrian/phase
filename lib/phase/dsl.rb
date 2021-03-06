module Phase
  module DSL

    # @param [String] role_name The value of the 'Role' tag
    # @param [String] environment The value of the 'Environment' tag
    # @param [Hash] options SSHKit concurrency options
    # @see SSHKit::Coordinator for concurrency options
    # @return [void]
    def on_role(role_name, environment = "staging", options = {}, &block)
      servers = ::Phase.servers.where(role: role_name, environment: environment)
      on(servers.map {|s| s.resource.private_ip_address }, options, &block)
    end

    def on(destination_ips, options = {}, &block)
      server = ::Phase.servers.where(role: ::Phase.config.bastion_role).first
      raise ArgumentError, "no servers found" unless server

      # TODO: identify the CORRECT bastion host per subnet/network
      bastion_host = "#{ ::Phase.config.bastion_user }@#{ server.resource.dns_name }"
      coordinator  = ::SSHKit::Coordinator.new(bastion_host)

      # TODO: clean up this logic. this should be done within a coordinator
      # (or elsewhere) so we can ID networks on a per-adapter basis
      results = Array(destination_ips).map do |ip|
        coordinator.each(options) do
          on_remote_host(ip) { instance_exec(&block) }
        end
      end

      results.flatten
    end

    def run_locally(&block)
      ::SSHKit::Backend::Local.new(&block).run
    end

  end
end

include ::Phase::DSL
