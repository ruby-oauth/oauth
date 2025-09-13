# frozen_string_literal: true

begin
  require "curb"
  require "oauth/request_proxy/curb_request"

  RSpec.describe OAuth::RequestProxy::CurbRequest do
    it "is constructible when curb is available" do
      req = Curl::Easy.new("http://example.com/test?a=1")
      proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/test"})
      expect(proxy.method).to be_a(String)
    end
  end
rescue LoadError
  RSpec.describe "OAuth Curb Request Proxy" do
    it "is pending because curb is not installed" do
      skip("curb not installed")
    end
  end
end
