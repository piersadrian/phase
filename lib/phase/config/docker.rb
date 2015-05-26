module Phase
  module Config
    class Docker

      # @return [String] the compact or fully-qualified address of the Docker repository
      # @example Sample settings
      #   config.docker.repository = "mycompany/myrepo"
      #   config.docker.repository = "https://docker.mycompany.com/myrepo"
      attr_accessor :repository

    end
  end
end
