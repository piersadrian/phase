module Phase
  class Configuration

    attr_accessor :bastions_enabled, :bastion_role, :bastion_user, :public_subnet_name,
                  :private_subnet_name, :aws_region, :adapter, :backend

    def initialize
      @bastions_enabled     = false
      @bastion_role         = nil
      @bastion_user         = nil
      @public_subnet_name   = "public"
      @private_subnet_name  = "private"
      @aws_region           = "us-east-1"
      @adapter              = ::Phase::Adapters::AWS

      self.backend = ::Phase::SSH::Backend
      set_aws_credentials!
    end

    def backend=(backend)
      @backend = backend
      ::SSHKit.config.backend = @backend
    end

    # @see Phase::Config::Deploy
    def deploy
      @deploy ||= Config::Deploy.new
    end

    # @see Phase::Config::IPA
    def ipa
      @ipa ||= Config::IPA.new
    end

    def load_phasefile!
      if ::File.exist?(phasefile_path)
        load phasefile_path
      end
    end

    def set_aws_credentials!(access_key_id = nil, secret_access_key = nil)
      Fog.credentials = {
        aws_access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID', access_key_id),
        aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', secret_access_key)
      }
    end

    private

      def phasefile_path
        @phasefile_path ||= ::File.join(::Dir.pwd, 'Phasefile')
      end
  end
end
