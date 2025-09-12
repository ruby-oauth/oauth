# frozen_string_literal: true

begin
  require "action_controller"
  require "oauth/request_proxy/action_controller_request"

  RSpec.describe OAuth::RequestProxy::ActionControllerRequest do
    it "proxies ActionController::TestRequest with params" do
      # Use a minimal Rack env that ActionController::TestRequest can wrap
      env = {
        "REQUEST_METHOD" => "GET",
        "rack.input" => StringIO.new(""),
        "QUERY_STRING" => "foo=bar",
        "PATH_INFO" => "/widgets",
      }
      req = ActionController::TestRequest.create(env)

      proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/widgets"})
      expect(proxy.method).to eq("GET")
      expect(proxy.normalized_uri).to eq("http://example.com/widgets")
      expect(proxy.parameters).to include("foo" => ["bar"])
    end
  end
rescue LoadError
  RSpec.describe "OAuth ActionController Request Proxy" do
    it "is pending because actionpack is not installed" do
      skip("actionpack not installed")
    end
  end
end
