# frozen_string_literal: true

require "net/http"

RSpec.describe "OAuth::Signature PLAINTEXT" do
  describe "::available_methods" do
    it "includes 'plaintext'" do
      expect(OAuth::Signature.available_methods).to include("plaintext")
    end
  end

  describe "verification" do
    it "verifies example without token secret" do
      request = Net::HTTP::Get.new("/photos?file=vacation.jpg&size=original&oauth_version=1.0&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_signature=kd94hf93k423kf44%26&oauth_timestamp=1191242096&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=PLAINTEXT")

      consumer = OAuth::Consumer.new("dpf43f3p2l4k3l03", "kd94hf93k423kf44")
      token = OAuth::Token.new("nnch734d00sl2jdk", nil)

      expect(
        OAuth::Signature.verify(
          request,
          consumer: consumer,
          token: token,
          uri: "http://photos.example.net/photos",
        ),
      ).to be true
    end

    it "verifies example with token secret" do
      request = Net::HTTP::Get.new("/photos?file=vacation.jpg&size=original&oauth_version=1.0&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_signature=kd94hf93k423kf44%26pfkkdhi9sl3r4s00&oauth_timestamp=1191242096&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=PLAINTEXT")

      consumer = OAuth::Consumer.new("dpf43f3p2l4k3l03", "kd94hf93k423kf44")
      token = OAuth::Token.new("nnch734d00sl2jdk", "pfkkdhi9sl3r4s00")

      expect(
        OAuth::Signature.verify(
          request,
          consumer: consumer,
          token: token,
          uri: "http://photos.example.net/photos",
        ),
      ).to be true
    end
  end
end
