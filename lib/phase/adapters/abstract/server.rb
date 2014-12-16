module Phase
  module Adapters
    module Abstract
      class Server < Base

        class << self
          def all
            raise NotImplementedError
          end

          def find(server_id)
            raise NotImplementedError
          end

          def where(options = {})
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
