module Phase
  module Adapters
    class AWS
      require 'capistrano/all'

      def find_in(opts = {})
        query = {}

        if opts[:role]
          query["tag:Role"] = opts[:role]
        end

        ec2.servers.all(query).map do |h|
          { hostname: h.dns_name }
        end
      end

      def on(hosts, options = {}, &block)
        # results = []
        #
        # all.each do |bastion|
        #   if bastion.ssh("ls #{ LOCKFILE_NAME }").first.status == 0
        #     fail "Another phase operation is in progress."
        #   end
        #
        #   commands = ["touch #{ LOCKFILE_NAME }", *cmds, "rm #{ LOCKFILE_NAME }"]
        #   results << bastion.ssh(commands)
        # end
        #
        # results.last[-2]

        options.merge!(user: "orca")
        super(hosts, options, &block)

      # Ensure to handle Fog::SSH raising on SSH connection errors.
      # ensure
      #   all.each { |b| b.ssh("rm #{ LOCKFILE_NAME }") }
      end

      def ec2
        @ec2 ||= ::Fog::Compute::AWS.new
      end

    end
  end
end
