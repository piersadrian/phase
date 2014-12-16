module Phase
  module Adapters
    module AWS
      class Subnet < ::Phase::Adapters::Abstract::Base

        # @param [Hash] options Filtering options
        # @see Phase::Adapters::AWS::Server.where Additional filter documentation
        # @return [Array<AWS::Server>] The AWS instances within this VPC
        def servers(options = {})
          options[:subnet_id] = resource.subnet_id
          Server.where(options)
        end

        class << self
          # @return [Array<AWS::Subnet>] All known subnets
          def all
            where
          end

          # @param [String] subnet_id The ID of the requested subnet
          # @return [AWS::Subnet, nil] The requested subnet
          def find(subnet_id)
            new(api.subnets.get(subnet_id))
          end

          # @param [Hash] options Filtering options
          # @option options [String] :vpc_id The ID of a VPC
          # @option options [String] :name The value of the 'Name' tag
          # @return [Array<AWS::Subnet>] All subnets matching the optional filters
          def where(options = {})
            filters = {}

            filters["vpc-id"] = options[:vpc_id] if options[:vpc_id]
            filters["tag:Name"] = options[:name] if options[:name]

            api.subnets.all(filters).map {|subnet| new(subnet) }
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
