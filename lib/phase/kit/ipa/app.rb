module Phase
  module IPA
    class App
      attr_reader :qualified_path, :name, :version
      attr_accessor :download_url

      def initialize(qualified_path, version)
        @qualified_path, @version = qualified_path, version
        @name = ::File.basename(qualified_path, ".ipa")
      end

      def ipa_filename
        "#{bundle_name}-#{version}.ipa"
      end

      def plist_filename
        "#{bundle_name}-#{version}.plist"
      end

      def plist_xml
        xml = ::File.read( ::File.expand_path("../../templates/ipa_xml.plist", __dir__) )
        ::ERB.new(xml).result(binding)
      end

      private

        def bundle_name
          name
        end

        def bundle_id_prefix
          Phase.config.ipa.bundle_id_prefix
        end

        def company_name
          Phase.config.ipa.company_name
        end

        def full_image_url
          Phase.config.ipa.full_image_url
        end

        def human_name
          name.titleize
        end

        def icon_image_url
          Phase.config.ipa.icon_image_url
        end

    end
  end
end
