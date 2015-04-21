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
    end

    def backend=(backend)
      @backend = backend
      ::SSHKit.config.backend = @backend
    end
  end
end
