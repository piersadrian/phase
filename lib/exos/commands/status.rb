module Exos
  module Commands
    class Status < Command

      command :status do |c|
        c.syntax = "exos status"
        c.description = "Prints the current status of configured VPCs, subnets, and EC2 instances."
        c.action do |args, options|
          new(args, options).run
        end
      end

      def run
        @vpcs    = ec2.vpcs
        @subnets = ec2.subnets
        @servers = ec2.servers
        @elbs    = elb.load_balancers

        print_vpc_tables
        print_servers_table
      end

      def print_vpc_tables
        @vpcs.each do |vpc|
          table = ::Terminal::Table.new(title: "VPC Status")

          add_section_headers(table, ["VPC ID", "Name", "State", "CIDR Block", "Tenancy"])
          color = vpc.state == "available" ? :green : :light_red
          add_row(table, color, [
            vpc.id,
            vpc.tags["Name"] || vpc.tags["name"],
            vpc.state,
            vpc.cidr_block,
            vpc.tenancy
          ])

          subnets = @subnets.select do |subnet|
            subnet.vpc_id == vpc.id
          end

          return unless subnets.any?

          add_section_headers(table, ["Subnet ID", "Name", "State", "CIDR Block", "Availability Zone"])
          subnets.each do |subnet|
            color = subnet.ready? ? :green : :light_red
            add_row(table, color, [
              subnet.subnet_id,
              subnet.tag_set["Name"] || subnet.tag_set["name"],
              subnet.state,
              subnet.cidr_block,
              subnet.availability_zone
            ])
          end

          puts table
        end
      end

      def print_servers_table
        table  = ::Terminal::Table.new(title: "Instances")
        groups = @servers.group_by(&:subnet_id)

        add_section_headers(table, ["ID", "Name", "Type", "State", "Public IP", "Private IP", "Subnet Name"])

        groups.each_pair do |subnet_id, servers|
          servers.each do |server|
            color = server.ready? ? :green : :light_red
            subnet = @subnets.find { |s| s.subnet_id == subnet_id }
            subnet_name = subnet.tag_set["Name"] || subnet.tag_set["name"] if subnet

            add_row(table, color, [
              server.id,
              server.tags["Name"] || server.tags["name"],
              server.flavor_id,
              server.state,
              server.public_ip_address,
              server.private_ip_address,
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
