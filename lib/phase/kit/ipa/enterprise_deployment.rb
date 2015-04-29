module Phase
  module IPA
    class EnterpriseDeployment
      include ::Phase::Util::Console

      attr_reader :version, :file_paths, :aws, :bucket, :prefix, :apps

      def initialize(version, *filenames)
        @version = version
        @file_paths = filenames.map do |name|
          ::Dir.glob( ::File.expand_path(name) )
        end

        @file_paths.flatten!
        @file_paths.uniq!

        @aws = ::Fog::Storage::AWS.new(region: Phase.config.aws_region)
        @bucket = aws.directories.get(Phase.config.ipa.bucket_name)
        @prefix = ::Pathname.new(Phase.config.ipa.directory_prefix)

        @apps = []
      end

      def run!
        ::FileUtils.mkdir(version) rescue nil

        manifest_path = ::File.join(::Dir.pwd, version, "manifest.txt")
        ::File.open(manifest_path, 'w') do |manifest|
          file_paths.map do |path|
            app = App.new(path, version)
            app.download_url = download_url(app)

            log "#{app.name}: writing .plist..."
            write_plist!(app)

            log "#{app.name}: copying .ipa..."
            copy_ipa!(app)

            log "#{app.name}: uploading files..."
            upload!(app)

            log "#{app.name}: updating manifest..."
            manifest << manifest_url(app)
            manifest << "\n"

            log "#{app.name}: done"
            log ""
          end
        end
      end

      def write_plist!(app)
        ::File.open(plist_path(app), 'w') { |file| file << app.plist_xml }
      end

      def copy_ipa!(app)
        ::FileUtils.cp(app.qualified_path, ipa_path(app))
      end

      def upload!(app)
        ipa = bucket.files.new({
          key: prefix.join(app.ipa_filename),
          body: ::File.open(ipa_path(app)),
          acl: "public-read"
        })

        plist = bucket.files.new({
          key: prefix.join(app.plist_filename),
          body: ::File.open(plist_path(app)),
          acl: "public-read"
        })

        ipa.save
        plist.save
      end

      private

        def download_url(app)
          [
            "https://s3.amazonaws.com",
            bucket.key,
            prefix,
            app.ipa_filename
          ].join("/")
        end

        def manifest_url(app)
          [
            "itms-services://?action=download-manifest&url=https://s3.amazonaws.com",
            bucket.key,
            prefix,
            app.plist_filename
          ].join("/")
        end

        def plist_path(app)
          ::File.join(::Dir.pwd, version, app.plist_filename)
        end

        def ipa_path(app)
          ::File.join(::Dir.pwd, version, app.ipa_filename)
        end

    end
  end
end
