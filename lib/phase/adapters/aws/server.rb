module Phase
  module Adapters
    module AWS
      class Server < ::Phase::Adapters::Abstract::Server

        class << self
          # @return [Array<AWS::Server>] All known EC2 instances
          def all
            where
          end

          # @param [String] instance_id The ID of the requested EC2 instance
          # @return [AWS::Server] The requested EC2 instance
          def find(instance_id, options = {})
            new(api.servers.get(instance_id))
          end

          # @param [Hash] options Filtering options
          # @option options [String] :vpc_id The ID of a VPC
          # @option options [String] :name The value of the 'Name' tag
          # @option options [String] :role The value of the 'Role' tag
          # @option options [String] :environment The value of the 'Environment' tag
          # @option options [Array<String>] :instance_ids A list of specific instance IDs
          # @option options [String] :subnet_id The ID of a subnet
          # @return [Array<AWS::Server>] All EC2 instances matching the optional filters
          def where(options = {})
            filters = {}

            filters["vpc-id"] = options.delete(:vpc_id)       if options[:vpc_id]
            filters["tag:Name"] = options.delete(:name)       if options[:name]
            filters["instance-ids"] = options.delete(:ids)    if options[:ids]
            filters["subnet-id"] = options.delete(:subnet_id) if options[:subnet_id]

            filters["tag:Role"] = options.delete(:role)               if options[:role]
            filters["tag:Environment"] = options.delete(:environment) if options[:environment]

            if options.any?
              raise ArgumentError, "Unknown filters '#{options.keys.join(", ")}'!"
            end

            api.servers.all(filters).map {|server| new(server) }
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
