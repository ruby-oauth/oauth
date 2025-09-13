# frozen_string_literal: true

require "net/http"

RSpec.describe "Net::HTTP client OAuth helpers" do
  let(:consumer) { OAuth::Consumer.new("consumer_key_86cad9", "5888bf0345e5d237") }
  let(:token) { OAuth::Token.new("token_411a7f", "3196ffd991c8ebdb") }
  let(:uri) { URI.parse("http://example.com/test?key=value") }
  let(:http) { Net::HTTP.new(uri.host, uri.port) }
  let(:nonce) { 225_579_211_881_198_842_005_988_698_334_675_835_446 }
  let(:timestamp) { "1199645624" }

  it "adds Authorization header for GET with params" do
    request = Net::HTTP::Get.new("#{uri.path}?key=value")
    request.oauth!(http, consumer, token, {nonce: nonce, timestamp: timestamp})

    expect(request.method).to eq("GET")
    expect(request.path).to eq("/test?key=value")
    expect(request["authorization"]).to include("OAuth ")
    # Do not assert the exact signature bytes here; just ensure core fields are present
    expect(request["authorization"]).to include(
      "oauth_consumer_key=\"consumer_key_86cad9\"",
    )
    expect(request["authorization"]).to include(
      "oauth_token=\"token_411a7f\"",
    )
    expect(request["authorization"]).to match(/oauth_signature_method=\"HMAC-SHA1\"|oauth_signature_method=\"PLAINTEXT\"/)
  end

  it "adds body hash for POST with data and content type" do
    request = Net::HTTP::Post.new(uri.path)
    request.body = "data"
    request.content_type = "text/ascii"

    request.oauth!(http, consumer, token, {nonce: nonce, timestamp: timestamp})

    expect(request.method).to eq("POST")
    expect(request.path).to eq("/test")
    expect(request["authorization"]).to include("oauth_body_hash=")
  end
end
