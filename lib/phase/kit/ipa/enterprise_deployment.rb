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
        @bucket = aws.directories.get(Phase.config.ipa_bucket_name)
        @prefix = ::Pathname.new(Phase.config.ipa_directory_prefix)

        @apps = []
      end

      def run!
        ::FileUtils.mkdir(version) rescue nil

        @apps = file_paths.map do |path|
          app = App.new(path, version)
          write_plist!(app)
          copy_ipa!(app)
          upload!(app)
        end

        write_manifest!
      end

      def write_manifest!
        ::File.join(::Dir.pwd, version, "manifest.txt") do |file|
          apps.each { |app| file << app.install_link }
        end
      end

      def write_plist!(app)
        log "#{app.name}: writing .plist"
        ::File.open(plist_path(app), 'w') { |file| file << app.plist_xml }
      end

      def copy_ipa!(app)
        log "#{app.name}: copying .ipa"
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

        log "#{app.name}: uploading .ipa"
        ipa.save

        log "#{app.name}: uploading .plist"
        plist.save
      end

      private

        def plist_path(app)
          ::File.join(::Dir.pwd, version, app.plist_filename)
        end

        def ipa_path(app)
          ::File.join(::Dir.pwd, version, app.ipa_filename)
        end

    end
  end
end
