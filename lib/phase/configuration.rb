module Phase
  class Configuration

    attr_accessor :bastions_enabled, :bastion_role, :bastion_user, :public_subnet_name,
                  :private_subnet_name, :aws_region, :adapter, :backend,
                  :bundle_id_prefix, :ipa_directory_prefix, :ipa_bucket_name

    def initialize
      @bastions_enabled     = false
      @bastion_role         = nil
      @bastion_user         = nil
      @public_subnet_name   = "public"
      @private_subnet_name  = "private"
      @aws_region           = "us-east-1"
      @adapter              = ::Phase::Adapters::AWS

      @bundle_id_prefix     = ""
      @ipa_directory_prefix = ""
      @ipa_bucket_name      = ""

      self.backend = ::Phase::SSH::Backend
      set_aws_credentials!
    end

    def backend=(backend)
      @backend = backend
      ::SSHKit.config.backend = @backend
    end

    def load_phasefile!
      if ::File.exist?(phasefile_path)
        load phasefile_path
      end
    end

    def set_aws_credentials!
      Fog.credentials = {
        aws_access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
      }
    end

    private

      def phasefile_path
        @phasefile_path ||= ::File.join(::Dir.pwd, 'Phasefile')
      end
  end
end
