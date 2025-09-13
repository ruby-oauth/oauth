# frozen_string_literal: true

begin
  require "action_controller"
  require "oauth/request_proxy/action_controller_request"

  RSpec.describe OAuth::RequestProxy::ActionControllerRequest do
    it "proxies ActionController::TestRequest with params" do
      # Use a minimal Rack env that ActionController::TestRequest can wrap.
      # In Rails 8, TestRequest parameter parsing relies on the request body for form-encoded POSTs.
      env = {
        "REQUEST_METHOD" => "POST",
        "rack.input" => StringIO.new("foo=bar"),
        "CONTENT_TYPE" => "application/x-www-form-urlencoded",
        "PATH_INFO" => "/widgets",
      }
      req = ActionDispatch::Request.new(env)

      proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/widgets"})
      expect(proxy.method).to eq("POST")
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
