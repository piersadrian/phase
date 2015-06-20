module Phase
  module Util
    module Shell
      include Console

      def shell(*args)
        options = args.extract_options!
        options.reverse_merge!({
          allow_failure: false
        })

        log "running: #{args.join(' ')}"
        succeeded = !!system(*args) || options[:allow_failure]

        yield $? unless succeeded

        succeeded
      end

    end
  end
end
