module Phase
  module SSH
    class Coordinator < ::SSHKit::Coordinator

      private

        # Prevents Coordinator from uniqifing @raw_hosts.
        def resolve_hosts
          @raw_hosts.map { |rh| rh.is_a?(::SSHKit::Host) ? rh : ::SSHKit::Host.new(rh) }
        end
    end
  end
end
