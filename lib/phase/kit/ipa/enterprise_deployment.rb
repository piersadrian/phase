module Phase
  module IPA
    class EnterpriseDeployment
      attr_reader :version, :file_paths

      def initialize(version, *filenames)
        @version = version
        @file_paths = filenames.map do |name|
          ::Dir.glob( ::File.expand_path(name) )
        end

        @file_paths.flatten!
        @file_paths.uniq!
      end

      def build!
        ::FileUtils.mkdir(version) rescue nil

        file_paths.each do |path|
          name = ::File.basename(path, ".ipa")
          app  = App.new(name, version)

          plist_path = ::File.join(::Dir.pwd, version, app.plist_filename)
          ipa_path   = ::File.join(::Dir.pwd, version, app.ipa_filename)

          ::File.open(plist_path, 'w') { |file| file << app.plist_xml }
          ::FileUtils.cp(path, ipa_path)
        end
      end

      def apps
        @apps ||= file_paths.map do |path|
          App.new(::File.basename(path, ".ipa"), version)
        end
      end

    end
  end
end
