module Phase
  module Adapters
    module AWS
      class LoadBalancer < ::Phase::Adapters::Abstract::LoadBalancer

        # @param [String] server_id The ID of the instance to deregister
        # @return [AWS::Server] The deregistered EC2 instance
        def deregister_server(server_id, options = {})
        end

        # @param [String] server_id The ID of the instance to register
        # @return [AWS::Server] The registered EC2 instance
        def register_server(server_id, options = {})
        end

        # @return [Array<AWS::Server>] The EC2 instances registered to this ELB instance
        def servers
          Server.all(instance_ids: resource.instances)
        end

        class << self
          # @param [String] balancer_name The name of the requested ELB instance
          # @return [AWS::LoadBalancer] The requested ELB instance
          def find(balancer_name)
            new(api.load_balancers.get(balancer_name))
          end

          private

            def api
              @api ||= ::Fog::AWS::ELB.new(region: ::Phase.config.aws_region)
            end
        end

      end
    end
  end
end
