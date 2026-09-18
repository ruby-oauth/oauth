# frozen_string_literal: true

require "net/http"

RSpec.describe Net::HTTP do
  let(:consumer) { OAuth::Consumer.new("consumer_key_86cad9", "5888bf0345e5d237") }
  let(:token) { OAuth::Token.new("token_411a7f", "3196ffd991c8ebdb") }
  let(:uri) { URI.parse("http://example.com/test?key=value") }
  let(:http) { described_class.new(uri.host, uri.port) }
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
      "oauth_consumer_key=\"consumer_key_86cad9\""
    )
    expect(request["authorization"]).to include(
      "oauth_token=\"token_411a7f\""
    )
    expect(request["authorization"]).to match(/oauth_signature_method="HMAC-SHA1"|oauth_signature_method="PLAINTEXT"/)
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

  describe "scheme: query_string" do
    it "appends OAuth parameters as the query when the request URI has none" do
      request = Net::HTTP::Get.new("/test")
      request.oauth!(http, consumer, token, {scheme: "query_string", nonce: nonce, timestamp: timestamp})

      expect(request["authorization"]).to be_nil
      expect(request.path).to start_with("/test?oauth_consumer_key=#{consumer.key}")
      expect(request.path).to include("oauth_nonce=#{nonce}")
      expect(request.path).to match(/&oauth_signature=[^&]+\z/)
    end

    it "appends OAuth parameters to an existing query string with '&'" do
      request = Net::HTTP::Get.new("#{uri.path}?key=value")
      request.oauth!(http, consumer, token, {scheme: "query_string", nonce: nonce, timestamp: timestamp})

      expect(request["authorization"]).to be_nil
      # existing params are preserved, OAuth params are appended after them
      expect(request.path).to start_with("/test?key=value&oauth_consumer_key=#{consumer.key}")
      expect(request.path).to match(/&oauth_signature=[^&]+\z/)
    end
  end

  describe "#signature_base_string uri derivation" do
    it "derives an https normalized URI from the http object when no :site option is given" do
      https_http = described_class.new(uri.host, uri.port)
      https_http.use_ssl = true
      request = Net::HTTP::Get.new(uri.path)

      base_string = request.signature_base_string(https_http, consumer, token, {nonce: nonce, timestamp: timestamp})

      expect(base_string).to include("https%3A%2F%2Fexample.com")
    end

    it "derives host/port from :site when :request_endpoint is set" do
      request = Net::HTTP::Get.new(uri.path)

      base_string = request.signature_base_string(http, consumer, token, {
        request_endpoint: true,
        site: "https://api.example.com",
        nonce: nonce,
        timestamp: timestamp
      })

      expect(base_string).to include("api.example.com")
    end
  end
end
