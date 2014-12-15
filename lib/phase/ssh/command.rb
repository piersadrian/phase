module Phase
  module SSH
    class Command < ::SSHKit::Command

      def on_remote_host(&block)
        return yield unless options[:remote_host]
        "ssh #{ options[:remote_host] } -- %s" % yield
      end

      def to_command
        on_remote_host { super }
      end

    end
  end
end
