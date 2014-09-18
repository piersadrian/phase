require 'json'

module Cloud
  module Commands
    class Keys < Command

      command :keys do |c|
        c.syntax = "cloud keys [-a email_address|-r email_address] [-k public_key]"

        c.option "-a", "--add email_address", String, "Add access for user with email_address."
        c.option "-r", "--revoke email_address", String, "Remove access for user with email_address."
        c.option "-d", "--delete", "Delete key entry permanently. Defaults to false (comments-out instead)."
        # c.option "-k", "--key public_key", String, "Public key of new user. Required when '-a, --add email_address' is used."
        c.option "-r", "--role bastion_role", String, "Value of 'Role' tag for bastion hosts. Defaults to 'ssh'."
        c.option "-l", "--list", "Default action. Lists email addresses and public keys of users with access."

        c.description = "Adds or removes access by email address and public key on bastion servers."
        c.action do |args, options|
          options.default role: "ssh", delete: false
          new(args, options).run
        end
      end

      PATTERN_KEY_LINE   = /\A#? ?ssh-rsa/
      PATTERN_ATTRS_LINE = /\A# cloud-key (.*)/

      def run
        if options.add
          key = ask("Enter public key:")
          add_key(options.add, key)
        elsif options.remove
          remove_key(options.remove, options.delete)
        else
          print_keys_list
        end
      end

      private

        def add_key(email, key)
          bastions.each do |bastion|
            found_key = current_keys.find do |attrs|
              attrs["email"] == email || attrs["key"] == parse_key(key)["key"]
            end

            if found_key
              # switch on
              bastion.ssh("")
            else
              key_lines = serialize_key(email, key)
              bastion.ssh("echo #{ key_lines } > ~/.ssh/authorized_keys")
            end
          end
        end

        def remove_key(email, delete)

        end

        def set_key_status(email, active)

        end

        def print_keys_list
          table = ::Terminal::Table.new({
            title: "Users with access",
            headings: ["Email address", "Status", "Added at", "Updated at", "Public key"]
          })

          current_keys.each do |attrs|
            active = attrs["status"] == "active"
            key_fragment = attrs["key"][-24..-1]

            cells = [
              attrs["email"],
              attrs["status"],
              attrs["added"],
              attrs["updated"],
              key_fragment ? "..." + key_fragment : "(none)"
            ].map do |cell|
              cell.send( active ? :green : :red )
            end

            table << cells
          end

          puts table
        end

        def serialize_key(email, key)
          time_now = Time.now.to_s
          attrs_line = {
            email: email,
            status: "active",
            added_at: time_now,
            updated_at: time_now
          }

          ["# cloud-key #{ JSON.dump(attrs_line) }", key].join("\n")
        end

        def current_keys
          @current_keys ||= begin
            bastion = bastions.first
            keys = []

            lines = bastion.ssh("cat ~/.ssh/authorized_keys").first.stdout.lines.map(&:chomp)
            lines.reject! { |line| line.length == 0 }

            idx = 0
            while idx < lines.count
              attrs_line = lines[idx]
              key_line = lines[idx + 1]
              attrs = parse_attrs_and_key(attrs_line, key_line)
              keys.push(attrs) if attrs
              idx += 2
            end

            keys
          end
        end

        def parse_attrs_and_key(attrs_line, key_line)
          if attrs_line.match(PATTERN_ATTRS_LINE)
            attrs = JSON.parse($1)

            if key_line.match(PATTERN_KEY_LINE)
              attrs.merge!( parse_key(key_line) )
            end
          elsif attrs_line.match(PATTERN_KEY_LINE)
            attrs = parse_key(attrs_line)
            attrs.default = ""
          else
            return nil
          end

          attrs
        end

        def parse_key(key_line)
          attrs = {}
          # If commented, it's inactive.
          if key_line[0] == "#"
            attrs["status"] = "inactive"
            key_line.gsub!(/\A# ?/, "")
          else
            attrs["status"] = "active"
          end

          attrs["key"] = key_line.split[1]

          attrs
        end

        def bastions
          @bastions ||= begin
            bastions = ec2.servers.all("tag:Name" => "harpoon-1").map do |bastion|
              bastion.username = "deploy"
              bastion
            end

            abort "No bastions found with role '#{ options.role }'." unless bastions.any?
            bastions
          end
        end

    end
  end
end
