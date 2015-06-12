module Phase
  module Deploy

    class Version
      class << self

        def current
          ::File.read( ::Phase.config.deploy.version_lockfile ).chomp rescue nil
        end

        def next
          current.to_i + 1
        end

        def update(new_version)
          write_version(new_version)
        end

        private

          def write_version(new_version)
            ::File.open( ::Phase.config.deploy.version_lockfile, 'w' ) { |f| f.write(new_version) }
          end

      end
    end

  end
end
