module Phase
  module DSL

    # def on_role(role_name, options = {}, &block)
    #   destination_ips = []
    #   on(destination_ips, options, &block)
    # end

    def on(destination_ips, options = {}, &block)
      bastion_host = ["orca@54.165.207.98"]

      coordinator = SSH::Coordinator.new(bastion_host)

      destination_ips.each do |ip|
        coordinator.each(options) do
          on_remote_host(ip) { instance_exec(&block) }
        end
      end
    end

    def run_locally(&block)
      ::SSHKit::Backend::Local.new(&block).run
    end

  end
end

include ::Phase::DSL
