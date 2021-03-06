module Phase
  module Adapters
    module Abstract
      class Base

        attr_reader :resource

        def initialize(resource)
          @resource = resource
        end

        class << self
          private

            def api
              raise NotImplementedError
            end
        end

      end
    end
  end
end
