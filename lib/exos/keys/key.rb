module Phase
  module Keys
    class Key
      attr_accessor :email, :key, :created_at, :updated_at, :status

      PATTERN_KEY_LINE   = /ssh-rsa/
      PATTERN_ATTRS_LINE = /\A### phase-key (.*)/

      def self.parse(attrs_line, key_line)
        if attrs_line.match(PATTERN_ATTRS_LINE)
          attrs = JSON.parse($1)

          new_key = new(
            email:      attrs["email"],
            status:     attrs["status"],
            created_at: attrs["created_at"],
            updated_at: attrs["updated_at"]
          )

          if key_line.match(PATTERN_KEY_LINE)
            new_key.key = key_line.chomp
          end

          new_key
        end
      end

      def initialize(attrs = {})
        self.email      = attrs.fetch(:email)
        self.key        = attrs.fetch(:key, nil)
        self.status     = attrs.fetch(:status, "active")
        self.created_at = attrs.fetch(:created_at, Time.now)
        self.updated_at = attrs.fetch(:updated_at, Time.now)
      end

      def key=(text)
        if text && !text.match(/\A(# )?ssh-rsa .+/)
          raise ArgumentError, "Invalid key."
        end

        @key = text
      end

      def key_fragment
        "..." + uncomment(self.key).split[1][-20..-1] if self.key
      end

      def attributes
        {
          email:      self.email,
          status:     self.status,
          created_at: self.created_at,
          updated_at: self.updated_at
        }
      end

      def touch
        self.updated_at = Time.now
      end

      def valid?
        !!self.email && !!self.key
      end

      def active?
        self.status == "active"
      end

      def activate
        self.status = "active"
        self.key = uncomment(self.key)
      end

      def deactivate
        self.status = "inactive"
        self.key = comment(self.key)
      end

      def comment(key); "# #{key}"; end
      def uncomment(key); self.key.sub(/\A# /, ""); end

      def to_s
        escape( ["", "### phase-key #{ ::JSON.dump(attributes) }", self.key, ""].join("\n") )
      end

      def escape(text)
        text.gsub("'", "\'")
      end
    end
  end
end
