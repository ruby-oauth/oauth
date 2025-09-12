# frozen_string_literal: true

begin
  require "em-http-request"
  require "oauth/request_proxy/em_http_request"

  RSpec.describe "OAuth EM-HTTP Request Proxy" do
    it "is pending until em-http-request usage is exercised in tests" do
      skip("em-http-request adapter not exercised in this environment")
    end
  end
rescue LoadError
  RSpec.describe "OAuth EM-HTTP Request Proxy" do
    it "is pending because em-http-request is not installed" do
      pending("em-http-request not installed")
      raise "unreachable"
    end
  end
end
