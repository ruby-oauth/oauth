# frozen_string_literal: true

begin
  require "rest-client"
  require "oauth/request_proxy/rest_client_request"

  RSpec.describe OAuth::RequestProxy::RestClient::Request do
    it "is constructible when rest-client is available" do
      req = RestClient::Request.new(method: :get, url: "http://example.com/test?x=1")
      proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/test"})
      expect(proxy.method).to eq("GET")
      expect(proxy.parameters).to include("x" => ["1"])
    end
  end
rescue LoadError
  RSpec.describe "OAuth RestClient Request Proxy" do
    it "is pending because rest-client is not installed" do
      pending("rest-client not installed")
      raise "unreachable"
    end
  end
end
