require 'json'

module Cloud
  module Commands
    class Keys < Command

      command :keys do |c|
        c.syntax = "cloud keys [-a email_address] [-r email_address [--delete]] [-r bastion_role]"

        c.option "--grant email_address", String, "Add access for user with email_address."
        c.option "--revoke email_address", String, "Revoke access for user with email_address."
        c.option "--delete", "Delete key entry permanently. Defaults to false (comments-out instead)."
        c.option "--role bastion_role", String, "Value of 'Role' tag for bastion hosts. Defaults to 'ssh'."
        c.option "--list", "Default action. Lists email addresses and public keys of users with access."

        c.description = "Adds or removes access by email address and public key on bastion servers."
        c.action do |args, options|
          options.default role: "ssh", delete: false
          new(args, options).run
        end
      end

      PATTERN_KEY_LINE   = /ssh-rsa/
      PATTERN_ATTRS_LINE = /\A### cloud-key (.*)/

      LOCKFILE_NAME = "cloud.keys.lock"

      def run
        authorized_keys.backup!

        if email = options.grant
          add_key(email)
        elsif email = options.revoke
          remove_key(email, options.delete)
        else
          print_keys_list
        end
      end

      private

        def authorized_keys
          @authorized_keys ||= AuthorizedKeys.new
        end

        def print_keys_list
          table = ::Terminal::Table.new({
            title: "Users with access",
            headings: ["Email address", "Status", "Created at", "Updated at", "Public key"]
          })

          authorized_keys.each do |_, auth_key|
            # Allow administrative keys to be hidden.
            next if auth_key.status == "IGNORE"

            cells = [
              auth_key.email,
              auth_key.status,
              auth_key.created_at,
              auth_key.updated_at,
              auth_key.key_fragment
            ].map do |cell|
              cell.to_s.send( auth_key.active? ? :green : :red )
            end

            table << cells
          end

          puts table
        end

        def add_key(email)
          if found_key = authorized_keys[email]
            found_key.activate
          else
            key_text = ask("Enter public key:")
            authorized_keys.add( Key.new(email: email, key: key_text) )
          end

          authorized_keys.persist!

          print_keys_list
        end

        def remove_key(email, delete)
          if found_key = authorized_keys[email]
            if delete
              authorized_keys.remove(found_key)
            else
              found_key.deactivate
            end

            authorized_keys.persist!
          else
            abort "No key found."
          end

          print_keys_list
        end


        class AuthorizedKeys < Hash
            def add(key)
              self[key.email] = key
            end

            def remove(key)
              delete(key.email)
            end

            def to_s
              reduce("") do |out, (_, key)|
                out << key.to_s
              end
            end

            def persist!
              Bastions.exec("echo '#{to_s}' > ~/.ssh/authorized_keys")
            end

            def backup!
              File.open( File.expand_path("~/.cloud-keys"), "w" ) { |file| file << raw_keys }
            end

            def initialize(*)
              super

              lines = raw_keys.lines.map(&:chomp).reject(&:empty?)

              idx = 0
              while idx < lines.count
                attrs_line = lines[idx]

                unless attrs_line.match(/\A### cloud-key/)
                  idx += 1
                  next
                end

                key_line = lines[idx + 1]
                add( Key.parse(attrs_line, key_line) )
                idx += 2
              end
            end

            private

              def raw_keys
                @raw_keys ||= Bastions.exec("cat ~/.ssh/authorized_keys").stdout
              end

              def reset!
                @raw_keys = nil
                @all = nil
              end
        end


        class Key
          attr_accessor :email, :key, :created_at, :updated_at, :status

          def self.parse(attrs_line, key_line)
            if attrs_line.match(PATTERN_ATTRS_LINE)
              attrs = JSON.parse($1)

              new_key = new(
                email:      attrs["email"],
                status:     attrs["status"],
                created_at: attrs["created_at"],
                updated_at: attrs["updated_at"]
              )

              if key_line.match(PATTERN_KEY_LINE)
                new_key.key = key_line.chomp
              end

              new_key
            end
          end

          def initialize(attrs = {})
            self.email      = attrs.fetch(:email)
            self.key        = attrs.fetch(:key, nil)
            self.status     = attrs.fetch(:status, "active")
            self.created_at = attrs.fetch(:created_at, Time.now)
            self.updated_at = attrs.fetch(:updated_at, Time.now)
          end

          def key=(text)
            if text && !text.match(/\A(# )?ssh-rsa .+/)
              abort "Invalid key."
            end

            @key = text
          end

          def key_fragment
            "..." + uncomment(self.key).split[1][-20..-1] if self.key
          end

          def attributes
            {
              email:      self.email,
              status:     self.status,
              created_at: self.created_at,
              updated_at: self.updated_at
            }
          end

          def touch
            self.updated_at = Time.now
          end

          def valid?
            !!self.email && !!self.key
          end

          def active?
            self.status == "active"
          end

          def activate
            self.status = "active"
            self.key = uncomment(self.key)
          end

          def deactivate
            self.status = "inactive"
            self.key = comment(self.key)
          end

          def comment(key); "# #{key}"; end
          def uncomment(key); self.key.sub(/\A# /, ""); end

          def to_s
            escape( ["", "### cloud-key #{ JSON.dump(attributes) }", self.key, ""].join("\n") )
          end

          def escape(text)
            text.gsub("'", "\'")
          end
        end


        class Bastions
          class << self

            def all
              @all ||= begin
                bastions = ec2.servers.all("tag:Name" => "harpoon-2").map do |bastion|
                  bastion.username = "deploy"
                  bastion
                end

                abort "No bastions found with role '#{ options.role }'." unless bastions.any?
                bastions
              end
            end

            def exec(*cmds)
              results = []

              all.each do |bastion|
                if bastion.ssh("ls #{ LOCKFILE_NAME }").first.status == 0
                  abort "Another `cloud keys` operation is in progress."
                end

                commands = ["touch #{ LOCKFILE_NAME }", *cmds, "rm #{ LOCKFILE_NAME }"]
                results << bastion.ssh(commands)
              end

              results.last[-2]
            # Ensure to handle Fog::SSH raising on SSH connection errors.
            ensure
              all.each { |b| b.ssh("rm #{ LOCKFILE_NAME }") }
            end

            def ec2
              @ec2 ||= ::Fog::Compute::AWS.new
            end

          end
        end

    end
  end
end
