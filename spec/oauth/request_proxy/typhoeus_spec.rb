# frozen_string_literal: true

begin
  require "typhoeus"
  require "oauth/request_proxy/typhoeus_request"

  RSpec.describe OAuth::RequestProxy::Typhoeus::Request do
    it "is constructible when typhoeus is available" do
      req = Typhoeus::Request.new("http://example.com/test", method: :get, params: {a: 1})
      proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/test"})
      expect(proxy.method).to eq("GET")
      expect(proxy.parameters).to include("a" => ["1"])
    end
  end
rescue LoadError
  RSpec.describe "OAuth Typhoeus Request Proxy" do
    it "is pending because typhoeus is not installed" do
      pending("typhoeus not installed")
      raise "unreachable"
    end
  end
end
