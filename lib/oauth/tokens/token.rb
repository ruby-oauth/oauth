# frozen_string_literal: true

module OAuth
  # Superclass for the various tokens used by OAuth.
  #
  # Includes {Auth::Sanitizer::FilteredAttributes} so inspect output redacts the
  # token value and token secret while leaving object identity and non-sensitive
  # fields visible.
  class Token
    include OAuth::Helper
    include Auth::Sanitizer::FilteredAttributes

    # Token attributes.
    #
    # @!attribute [rw] token
    #   @return [String] OAuth token value (redacted in `#inspect`)
    # @!attribute [rw] secret
    #   @return [String] OAuth token secret (redacted in `#inspect`)
    attr_accessor :token, :secret
    filtered_attributes :token, :secret

    def initialize(token, secret)
      @token = token
      @secret = secret
    end

    def to_query
      "oauth_token=#{escape(token)}&oauth_token_secret=#{escape(secret)}"
    end
  end
end
