# frozen_string_literal: true

begin
  require "rack"
  require "oauth/request_proxy/rack_request"

  RSpec.describe OAuth::RequestProxy::RackRequest do
    include Rack::Test::Methods

    def app
      proc { |_env| [200, {"Content-Type" => "text/plain"}, ["OK"]] }
    end

    it "proxies Rack::Request with query params" do
      get "/test", {"a" => "1", "b" => "2"}
      rack_req = last_request

      proxy = OAuth::RequestProxy.proxy(rack_req, {uri: "http://example.com/test"})

      expect(proxy.method).to eq("GET")
      expect(proxy.normalized_uri).to eq("http://example.org/test")
      # For Rack::Request proxy, parameters are simple strings, not arrays
      expect(proxy.parameters).to include("a" => "1", "b" => "2")
    end

    it "proxies Rack::Request POST form params" do
      post "/test", {"x" => "9", "y" => "10"}
      rack_req = last_request

      proxy = OAuth::RequestProxy.proxy(rack_req, {uri: "http://example.com/test"})

      expect(proxy.method).to eq("POST")
      # For Rack::Request proxy, parameters are simple strings, not arrays
      expect(proxy.parameters).to include("x" => "9", "y" => "10")
    end
  end
rescue LoadError
  RSpec.describe "OAuth Rack Request Proxy" do
    it "is pending because Rack is not available" do
      pending("rack not installed")
      raise "unreachable"
    end
  end
end
