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
        <<-EOXML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>items</key>
            <array>
              <dict>
                <key>assets</key>
                <array>
                  <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>https://s3.amazonaws.com/orca-static-assets/apps/#{ipa_filename}</string>
                  </dict>
                </array>
                <key>metadata</key>
                <dict>
                  <key>bundle-identifier</key>
                  <string>#{bundle_id_prefix}.#{bundle_name}</string>
                  <key>bundle-version</key>
                  <string>#{version}</string>
                  <key>kind</key>
                  <string>software</string>
                  <key>title</key>
                  <string>#{human_name}</string>
                </dict>
              </dict>
            </array>
          </dict>
          </plist>
        EOXML
      end

      private

        def human_name
          name.titleize
        end

        def bundle_name
          name.camelize
        end

        def bundle_id_prefix
          Phase.config.bundle_id_prefix
        end
    end
  end
end
