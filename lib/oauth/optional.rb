# frozen_string_literal: true

module OAuth
  # Helpers for optional, lazily loaded integrations.
  module Optional
    class << self
      # Try to load EventMachine HTTP client support provided by em-http-request.
      #
      # Returns true if available, false if the dependency is not installed.
      # Never raises LoadError.
      def em_http_available?
        # em-http-request provides "em-http" entrypoint
        require "em-http"
        true
      rescue LoadError
        false
      end
    end
  end
end
