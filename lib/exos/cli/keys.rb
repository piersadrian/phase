require 'json'

module Phase
  module Commands
    class Keys < Command

      command :keys do |c|
        c.syntax = "phase keys [--grant email_address] [--revoke email_address [--delete]] [--role bastion_role]"

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

      LOCKFILE_NAME = "phase.keys.lock"

      def run
        log "backing up existing keys..."
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
          @authorized_keys ||= AuthorizedKeys.new(bastions)
        end

        def bastions
          @bastions ||= begin
            bastions = find_hosts(role: options.role)
            fail "No bastions found with role '#{ role }'." unless bastions.any?
            bastions
          end
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
            authorized_keys.add( Keys::Key.new(email: email, key: key_text) )
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
            fail "No key found."
          end

          print_keys_list
        end


        class AuthorizedKeys
          extend ::Forwardable

          attr_reader :bastions

          def initialize(bastions)
            @bastions = bastions
            @hash = Hash.new
            fetch_keys
          end

          def fetch_keys
            lines = raw_keys.lines.map(&:chomp).reject(&:empty?)
            idx = 0
            while idx < lines.count
              attrs_line = lines[idx]

              unless attrs_line.match(/\A### phase-key/)
                idx += 1
                next
              end

              key_line = lines[idx + 1]
              add( Keys::Key.parse(attrs_line, key_line) )
              idx += 2
            end
          end

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
            log "writing new keys..."
            bastions.exec("echo '#{to_s}' > ~/.ssh/authorized_keys")
          end

          def backup!
            File.open( File.expand_path("~/.phase-keys"), "w" ) { |file| file << raw_keys }
          end

          private

            def raw_keys
              @raw_keys ||= bastions.exec("cat ~/.ssh/authorized_keys").stdout
            end

            def reset!
              @raw_keys = nil
              @all = nil
            end

          def_delegators :@hash, *(::Hash.instance_methods - AuthorizedKeys.instance_methods)
        end

    end
  end
end
