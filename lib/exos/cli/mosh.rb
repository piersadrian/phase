module Phase
  module Commands
    class Mosh < SSH

      command :mosh do |c|
        c.syntax = "phase mosh [-i instance_id] [-n instance_name] [-r instance_role] [-u user] [-c conn_str] [username@instance_name|instance_id]"

        c.option "-i", "--id instance_id", String, "Connects to the instance with this ID."
        c.option "-n", "--name instance_name", String, "Connects to the instance with this 'Name' tag."
        c.option "-r", "--role instance_role", String, "Connects to an instance with this 'Role' tag. Default is 'ssh'."
        c.option "-u", "--user username", String, "Remote username to connect with."
        c.option "-c", "--conn conn_str", String, "Invokes conn_str to establish terminal session (e.g. --conn='ssh -i key.pem')."

        c.description = "Connects to the the specified instance via mosh."
        c.action do |args, options|
          options.default role: "ssh", conn: "mosh --ssh='ssh -A'"
          new(args, options).run
        end
      end

    end
  end
end
