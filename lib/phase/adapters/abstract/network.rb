module Phase
  module Adapters
    module Abstract
      class Network < Base

        def servers
          raise NotImplementedError
        end

        class << self
          def all(network_id)
            raise NotImplementedError
          end

          def find(network_id)
            raise NotImplementedError
          end

          private

            def api
              raise NotImplementedError
            end
        end

      end
    end
  end
end
