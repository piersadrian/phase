module Phase
  class Command < ::SSHKit::Command
    def to_command
      "ssh 10.100.0.175 -- %s" % super
    end
  end
end
