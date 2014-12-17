module Phase
  class Configuration

    attr_accessor :use_bastions,
                  :bastion_role,
                  :bastion_user,

                  :aws_region,

                  :adapter

    def initialize
      @use_bastions = false
      @bastion_role = "ssh"
      @bastion_user = "orca"

      @aws_region   = "us-east-1"

      @adapter = ::Phase::Adapters::AWS

      ::SSHKit.config.backend = SSH::Backend

      configure_from_yml if defined?(::Rails) && yml_present?
    end

    def configure_from_yml
      yml_config = ::YAML.load_file(yml_path) || {}

      @use_bastions = yml_config[:use_bastions] if yml_config.has_key(:use_bastions)
      @bastion_role = yml_config[:bastion_role] if yml_config.has_key(:bastion_role)
      @bastion_user = yml_config[:bastion_user] if yml_config.has_key(:bastion_user)

      @aws_region = yml_config[:aws_region] if yml_config.has_key(:aws_region)
    end

    def yml_present?
      File.exists?(yml_path)
    end

    def yml_path
      # ::Rails.root.join("config", "phase.yml")
      ""
    end
  end
end
