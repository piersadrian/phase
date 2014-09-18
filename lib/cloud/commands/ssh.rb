module Cloud
  module Commands
    class SSH < Command

      command :ssh do |c|
        c.syntax = "cloud ssh [-i instance_id] [-n instance_name] [-r instance_role] [-u user] [username@instance_name|instance_id]"

        c.option "-i", "--id instance_id", String, "Connects to the instance with this ID."
        c.option "-n", "--name instance_name", String, "Connects to the instance with this 'Name' tag."
        c.option "-r", "--role instance_role", String, "Connects to an instance with this 'Role' tag. Default is 'ssh'."
        c.option "-u", "--user username", String, "Remote username to connect with."

        c.description = "Connects to the the specified instance. Tries to connect with mosh, then SSH."
        c.action do |args, options|
          options.default role: "ssh"
          new(args, options).run
        end
      end

      def run
        # Handle "connection string" style parameter.
        if conn = args.first
          user, str = conn.split("@")

          abort "Malformed parameter: user@[instance-name|instance-id]." if str.nil?

          str.match(/i-[0-9a-f]+/i) ? options.id = str : options.name = str
        else
          user = options.user
        end

        abort "Must specify username with -u or 'user@instance-name' parameter." if user.nil?

        if options.id
          instance = ec2.servers.all("instance-id" => options.id).first
        elsif options.name
          instance = ec2.servers.all("tag:Name" => options.name).first
        else
          instance = ec2.servers.all("tag:Role" => options.role).first
        end

        abort "No instance found. Exiting." if instance.nil?

        puts "Connecting to instance #{ instance.id }..."
        host = "#{ user }@#{ instance.dns_name }"

        begin
          exec "mosh #{ host }"
        rescue Errno::ENOENT
          exec "ssh #{ host }"
        end
      end

    end
  end
end
