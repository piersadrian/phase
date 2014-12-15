module Phase
  module Adapters
    module AWS
      class LoadBalancing < ::Phase::Adapters::Abstract::LoadBalancing

        def info(balancer_id)
        end

        def register_server(server_id)
        end

        def deregister_server(server_id)
        end

        def api
          @api ||= ::Fog::ELB.new(region: ::Phase.config.aws_region)
        end
      end
    end
  end
end
