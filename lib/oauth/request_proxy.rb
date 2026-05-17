# frozen_string_literal: true

module OAuth
  module RequestProxy
    AVAILABLE_PROXIES = {}

    class << self
      def available_proxies # :nodoc:
        AVAILABLE_PROXIES
      end

      def proxy(request, options = {})
        return request if request.is_a?(OAuth::RequestProxy::Base)

        klass = available_proxies[request.class]

        # Search for possible superclass matches.
        if klass.nil?
          request_parent = available_proxies.keys.find { |rc| request.is_a?(rc) }
          klass = available_proxies[request_parent]
        end

        raise UnknownRequestType, request.class.to_s unless klass

        klass.new(request, options)
      end
    end

    class UnknownRequestType < RuntimeError; end
  end
end
