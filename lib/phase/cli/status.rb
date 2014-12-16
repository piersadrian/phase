module Phase
  module CLI
    class Status < Command

      command :status do |c|
        c.syntax = "phase status"
        c.description = "Prints the current status of configured VPCs, subnets, and EC2 instances."
        c.action do |args, options|
          new(args, options).run
        end
      end

      def run
        @vpcs    = ::Phase::Adapters::AWS::Network.all
        @subnets = ::Phase::Adapters::AWS::Subnet.all
        @servers = ::Phase::Adapters::AWS::Server.all
        @elbs    = ::Phase::Adapters::AWS::LoadBalancer.all

        print_vpc_tables
        print_servers_table
      end

      def print_vpc_tables
        @vpcs.each do |vpc|
          table = ::Terminal::Table.new(title: "VPC Status")

          add_section_headers(table, ["VPC ID", "Name", "State", "CIDR Block", "Tenancy"])
          color = vpc.resource.state == "available" ? :green : :light_red
          add_row(table, color, [
            vpc.resource.id,
            vpc.resource.tags["Name"] || vpc.resource.tags["name"],
            vpc.resource.state,
            vpc.resource.cidr_block,
            vpc.resource.tenancy
          ])

          subnets = @subnets.select do |subnet|
            subnet.resource.vpc_id == vpc.resource.id
          end

          return unless subnets.any?

          add_section_headers(table, ["Subnet ID", "Name", "State", "CIDR Block", "Availability Zone"])
          subnets.each do |subnet|
            color = subnet.resource.ready? ? :green : :light_red
            add_row(table, color, [
              subnet.resource.subnet_id,
              subnet.resource.tag_set["Name"] || subnet.resource.tag_set["name"],
              subnet.resource.state,
              subnet.resource.cidr_block,
              subnet.resource.availability_zone
            ])
          end

          puts table
        end
      end

      def print_servers_table
        table  = ::Terminal::Table.new(title: "Instances")
        groups = @servers.group_by {|s| s.resource.subnet_id }

        add_section_headers(table, ["ID", "Name", "Type", "State", "Public IP", "Private IP", "Subnet Name"])

        groups.each_pair do |subnet_id, servers|
          servers.each do |server|
            color = server.resource.ready? ? :green : :light_red
            subnet = @subnets.find { |s| s.resource.subnet_id == subnet_id }
            subnet_name = subnet.resource.tag_set["Name"] || subnet.resource.tag_set["name"] if subnet

            add_row(table, color, [
              server.resource.id,
              server.resource.tags["Name"] || server.resource.tags["name"],
              server.resource.flavor_id,
              server.resource.state,
              server.resource.public_ip_address,
              server.resource.private_ip_address,
              subnet_name
            ])
          end
        end

        puts table
      end

      private

        def add_row(table, color_method, values)
          table << values.map { |v| (v || "").send(color_method) }
        end

        def add_section_headers(table, headers)
          table.add_separator if table.number_of_columns > 0
          table << headers
          table.add_separator
        end
    end
  end
end
