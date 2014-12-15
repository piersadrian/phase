module Phase
  module Adapters
    class AWS
      # require 'capistrano/all'
      require "fog/aws"

      def find_servers(options = {})
        query = {}

        if options[:role]
          query["tag:Role"] = options[:role]
        end

        ec2.servers.all(query).map do |h|
          {
            hostname: h.dns_name,
            user: "orca"
          }
        end
      end

      def ec2
        @ec2 ||= ::Fog::Compute::AWS.new(region: ::Phase.config.aws_region)
      end

    end
  end
end
