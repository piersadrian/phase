module Phase
  module Adapters
    module Abstract
      class Networking < Base

        def info(network_id, options = {})
          raise NotImplementedError
        end

      end
    end
  end
end
