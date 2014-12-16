module Phase
  module Adapters
    module Abstract
      class LoadBalancer < Base

        def deregister_server(server_id, options = {})
          raise NotImplementedError
        end

        def register_server(server_id, options = {})
          raise NotImplementedError
        end

        class << self
          def all(balancer_id)
            raise NotImplementedError
          end

          def find(balancer_id)
            raise NotImplementedError
          end
        end

      end
    end
  end
end
