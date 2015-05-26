module Phase
  module Config
    class IPA

      # @return [String] the bundle ID prefix
      # @example Sample setting
      #   config.ipa.bundle_id_prefix = "com.mycompany"
      attr_accessor :bundle_id_prefix


      # @return [String] the directory keypath (e.g. 'prefix' at S3) for storing uploaded files
      # @example Sample setting
      #   config.ipa.directory_prefix = "somedir/nesteddir"
      attr_accessor :directory_prefix


      # @return [String] the bucket for storing uploaded files
      # @example Sample setting
      #   config.ipa.bucket_name = "mycompany-enterprise-builds"
      attr_accessor :bucket_name


      # @return [String] the company name to provide with enterprise app installs
      # @example Sample setting
      #   config.ipa.company_name = "ACME Corp"
      attr_accessor :company_name


      # @return [String] the URL of a full-size (512px x 512px) app icon PNG
      # @example Sample setting
      #   config.ipa.full_image_url = "https://....png"
      attr_accessor :full_image_url


      # @return [String] the URL of a Springboard-size (72px x 72px) app icon PNG
      # @example Sample setting
      #   config.ipa.icon_image_url = "https://....png"
      attr_accessor :icon_image_url

    end
  end
end
