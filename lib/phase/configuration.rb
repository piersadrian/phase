module Phase
  class Configuration

    attr_accessor :use_bastions,
                  :bastion_role,
                  :bastion_user,
                  :public_subnet_name,
                  :private_subnet_name,
                  :aws_region,
                  :adapter,
                  :backend

    def initialize
      @use_bastions         = false
      @bastion_role         = "ssh"
      @bastion_user         = "orca"
      @public_subnet_name   = "public"
      @private_subnet_name  = "private"
      @aws_region           = "us-east-1"
      @adapter              = ::Phase::Adapters::AWS
      @backend              = ::Phase::SSH::Backend

      ::SSHKit.config.backend = @backend
      configure_from_yml!
    end

    private

      def configure_from_yml!
        return unless yml_present?

        yml_config = ::YAML.load_file(yml_path) || {}

        @use_bastions = yml_config[:use_bastions] if yml_config.has_key(:use_bastions)
        @bastion_role = yml_config[:bastion_role] if yml_config.has_key(:bastion_role)
        @bastion_user = yml_config[:bastion_user] if yml_config.has_key(:bastion_user)
        @public_subnet_name = yml_config[:public_subnet_name] if yml_config.has_key(:public_subnet_name)
        @private_subnet_name = yml_config[:private_subnet_name] if yml_config.has_key(:private_subnet_name)
        @aws_region = yml_config[:aws_region] if yml_config.has_key(:aws_region)
      end

      def yml_present?
        defined?(::Rails) && File.exists?( yml_path )
      end

      def yml_path
        ::Rails.root.join("config", "phase.yml")
      end
  end
end
