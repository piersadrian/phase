module Phase
  module Adapters
    module Abstract
      class LoadBalancing < Base

        def deregister_server(server_id, options = {})
          raise NotImplementedError
        end

        def info(balancer_id, options = {})
          raise NotImplementedError
        end

        def register_server(server_id, options = {})
          raise NotImplementedError
        end

      end
    end
  end
end
