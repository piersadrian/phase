module Phase
  module SSH
    class BastionCoordinator

      def initialize(bastion, destination_hosts)
        @bastion = bastion
        @destination_hosts = destination_hosts
      end

      def each(options = {}, &block)
        if hosts
          queue = Queue.new
          @destination_hosts.each {|host| queue << hosts }

          options = default_options.merge(options)
          options[:address_queue] = queue

          case options[:in]
          when :parallel then ::Phase::SSH::Runners::Parallel
          when :sequence then ::Phase::SSH::Runners::Sequential
          when :groups   then ::Phase::SSH::Runners::Group
          else
            raise RuntimeError, "Don't know how to handle run style #{options[:in].inspect}"
          end.new([@bastion] * @destination_hosts.count, options, &block).execute
        else
          Runners::Null.new(hosts, options, &block).execute
        end
      end

      # def run!(options = {}, &block)
      #   backend = Backend.new(@bastion, options)
      #
      #   results = @destination_hosts.each do |host|
      #     backend.run do
      #       on_remote_host(ip) { instance_exec(&block) }
      #     end
      #   end
      #
      #   results.flatten
      # end

    end
  end
end
