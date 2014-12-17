module Phase
  class << self
    def load_balancers
      adapter.const_get("LoadBalancer")
    end

    def networks
      adapter.const_get("Network")
    end

    def servers
      adapter.const_get("Server")
    end

    def subnets
      adapter.const_get("Subnet")
    end
  end
end
