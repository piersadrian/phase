module Phase
  module Adapters
    module Abstract
      class Base

        private

          def api
            raise NotImplementedError
          end

      end
    end
  end
end
