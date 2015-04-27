module Phase
  class Configuration

    attr_accessor :bastions_enabled, :bastion_role, :bastion_user, :public_subnet_name,
                  :private_subnet_name, :aws_region, :adapter, :backend,
                  :bundle_id_prefix

    def initialize
      @bastions_enabled     = false
      @bastion_role         = nil
      @bastion_user         = nil
      @public_subnet_name   = "public"
      @private_subnet_name  = "private"
      @aws_region           = "us-east-1"
      @adapter              = ::Phase::Adapters::AWS

      @bundle_id_prefix     = ""

      self.backend = ::Phase::SSH::Backend
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

    private

      def phasefile_path
        @phasefile_path ||= ::File.join(::Dir.pwd, 'Phasefile')
      end
  end
end
