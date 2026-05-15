# frozen_string_literal: true

require "net/http"
require "oauth/request_proxy/net_http"

RSpec.describe OAuth::RequestProxy::Net::HTTP::HTTPRequest do
  let(:uri) { URI.parse("http://example.com/test?key=value") }

  it "proxies Net::HTTP GET requests with query params" do
    req = Net::HTTP::Get.new("#{uri.path}?key=value")
    proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/test"})

    expect(proxy.method).to eq("GET")
    expect(proxy.normalized_uri).to eq("http://example.com/test")
    expect(proxy.parameters).to include("key" => ["value"])
  end

  it "includes form params for POST with form-encoded content type" do
    req = Net::HTTP::Post.new(uri.path)
    req["Content-Type"] = "application/x-www-form-urlencoded"
    req.body = "a=1&b=2"

    proxy = OAuth::RequestProxy.proxy(req, {uri: "http://example.com/test"})

    expect(proxy.method).to eq("POST")
    expect(proxy.parameters).to include("a" => ["1"], "b" => ["2"])
  end
end
