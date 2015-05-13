module Phase
  module Util
    module Shell
      include Console

      def shell(*args)
        log "running: #{args.join(' ')}"
        status = !!system(*args)
        yield $? unless status
        return status
      end

    end
  end
end
