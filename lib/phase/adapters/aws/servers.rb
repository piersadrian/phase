module Phase
  module Adapters
    module AWS
      class Servers < ::Phase::Adapters::Abstract::Servers

        # @return [Array<Fog::Compute::AWS::Server>] all known AWS instances
        def all(options = {})
          api.servers.all
        end

        # @param instance_id the ID of the requested AWS instance
        # @return [Fog::Compute::AWS::Server] the requested AWS instance
        # @raise [Fog::Errors::NotFound] if the ID is unknown to AWS
        def find(instance_id, options = {})
          api.servers.get(instance_id)
        end

        # @param role_name the role name of the requested AWS instances
        # @return [Array<Fog::Compute::AWS::Server>] all AWS instances whose 'Role' tag is role_name
        def find_by_role(role_name, options = {})
          query = {
            "tag:Role" => role_name
          }

          if vpc_id = options[:vpc_id]
            query["vpc-id"] = vpc_id
          end

          api.servers.all(query)
        end

        private

          def api
            @api ||= ::Fog::Compute::AWS.new(region: ::Phase.config.aws_region)
          end
      end
    end
  end
end
