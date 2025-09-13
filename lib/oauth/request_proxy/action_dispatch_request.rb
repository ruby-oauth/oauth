# frozen_string_literal: true

require "oauth/request_proxy/rack_request"

module OAuth
  module RequestProxy
    class ActionDispatchRequest < OAuth::RequestProxy::RackRequest
      proxies ::ActionDispatch::Request

      # Prefer the explicitly provided URI, which carries scheme/host info
      # when ActionDispatch env may be minimal in tests.
      def uri
        options[:uri] || super
      end

      # Rails' ActionDispatch proxy should expose array-style parameters
      # for request/query params to align with legacy oauth gem expectations.
      def parameters
        if options[:clobber_request]
          options[:parameters] || {}
        else
          rq = wrap_values(request_params)
          qq = wrap_values(query_params)
          params = rq.merge(qq).merge(header_params)
          params.merge(options[:parameters] || {})
        end
      end

      protected

      def query_params
        # ActionDispatch::Request responds to GET
        request.GET
      end

      def request_params
        if request.content_type && request.content_type.to_s.downcase.start_with?("application/x-www-form-urlencoded")
          request.POST
        else
          {}
        end
      end

      def wrap_values(hash)
        return {} unless hash
        hash.each_with_object({}) do |(k, v), acc|
          acc[k] = (v.is_a?(Array) || v.nil?) ? v : [v]
        end
      end
    end
  end
end
