module Phase
  module Adapters
    module Abstract
      class Servers < Base

        def all(options = {})
          raise NotImplementedError
        end

        def find(server_id, options = {})
          raise NotImplementedError
        end

        def find_by_role(role_name, options = {})
          raise NotImplementedError
        end

      end
    end
  end
end
