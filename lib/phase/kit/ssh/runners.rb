module Phase
  module SSH
    module Runners

      module BastionRunner
        def backend(host, &block)
          backend = ::Phase.config.backend.new(host)
          address = options[:address_queue].pop

          backend.run do
            on_remote_host(address) { instance_exec(&block) }
          end
        end
      end

      class Parallel < ::SSHKit::Runner::Parallel
        include BastionRunner
      end

      class Sequential < ::SSHKit::Runner::Sequential
        include BastionRunner
      end

      class Null < ::SSHKit::Runner::Null
        include BastionRunner
      end

    end
  end
end
