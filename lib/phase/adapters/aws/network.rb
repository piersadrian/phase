module Phase
  module Adapters
    module AWS
      class Network < ::Phase::Adapters::Abstract::Network

        # @param [Hash] options Filtering options
        # @see Phase::Adapters::AWS::Server.where Additional filter documentation
        # @return [Array<AWS::Server>] The AWS instances within this VPC
        def servers(options = {})
          options[:vpc_id] = resource.id
          Server.where(options)
        end

        # @return [Array<Fog::Compute::AWS::Subnet>] The subnets within this VPC
        def subnets
          Subnet.where(vpc_id: resource.id)
        end

        class << self
          # @return [Array<AWS::Network>] All known VPC instances
          def all
            api.vpcs.all.map {|network| new(network) }
          end

          # @param [String] network_id The ID of the requested VPC
          # @return [AWS::Network, nil] The requested VPC
          def find(network_id)
            new(api.vpcs.get(network_id))
          end

          private

            def api
              @api ||= ::Fog::Compute::AWS.new(region: ::Phase.config.aws_region)
            end
        end

      end
    end
  end
end
