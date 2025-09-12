# frozen_string_literal: true

begin
  require "action_dispatch"
  require "oauth/request_proxy/action_dispatch_request"

  RSpec.describe OAuth::RequestProxy::ActionDispatchRequest do
    it "proxies ActionDispatch::Request with params" do
      env = {
        "REQUEST_METHOD" => "GET",
        "rack.input" => StringIO.new(""),
        "QUERY_STRING" => "a=1&b=2",
        "PATH_INFO" => "/test",
      }
      req = ActionDispatch::Request.new(env)

      proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/test"})
      expect(proxy.method).to eq("GET")
      expect(proxy.normalized_uri).to eq("http://example.com/test")
      expect(proxy.parameters).to include("a" => ["1"], "b" => ["2"])
    end
  end
rescue LoadError
  RSpec.describe "OAuth ActionDispatch Request Proxy" do
    it "is pending because actionpack is not installed" do
      skip("actionpack not installed")
    end
  end
end
