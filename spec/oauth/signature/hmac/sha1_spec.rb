# frozen_string_literal: true

require "oauth/signature/hmac/sha1"

RSpec.describe OAuth::Signature::HMAC::SHA1 do
  describe "#verify" do
    it "returns true when the request signature is correct" do
      request = OAuth::RequestProxy::MockRequest.new(
        "method" => "POST",
        "uri" => "https://photos.example.net/initialize",
        "parameters" => {
          "oauth_consumer_key" => "dpf43f3p2l4k3l03",
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_timestamp" => "137131200",
          "oauth_nonce" => "wIjqoS",
          "oauth_callback" => "http://printer.example.com/ready",
          "oauth_version" => "1.0",
          "oauth_signature" => "xcHYBV3AbyoDz7L4dV10P3oLCjY=",
        },
      )

      expect(described_class.new(request, consumer_secret: "kd94hf93k423kf44").verify).to be true
    end

    it "returns false when the request signature is wrong" do
      # this guards against a historical bug in Base#==
      request = OAuth::RequestProxy::MockRequest.new(
        "method" => "POST",
        "uri" => "https://photos.example.net/initialize",
        "parameters" => {
          "oauth_consumer_key" => "dpf43f3p2l4k3l03",
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_timestamp" => "137131200",
          "oauth_nonce" => "wIjqoS",
          "oauth_callback" => "http://printer.example.com/ready",
          "oauth_version" => "1.0",
          "oauth_signature" => "xcHYBV3AbyoDz7L4dV10P3oLCjZ=",
        },
      )

      expect(described_class.new(request, consumer_secret: "kd94hf93k423kf44").verify).to be false
    end
  end
end
