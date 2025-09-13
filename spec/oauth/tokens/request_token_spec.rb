# frozen_string_literal: true

require "oauth/tokens/request_token"
require "oauth/consumer"

RSpec.describe OAuth::RequestToken do
  let(:consumer) { OAuth::Consumer.new("key", "secret", {}) }
  let(:request_token) { described_class.new(consumer, "key", "secret") }

  describe "authorize_url" do
    it "includes oauth_token and additional params when provided" do
      url = request_token.authorize_url(oauth_callback: "github.com")
      expect(url).to be_a(String)
      expect(url).to match(/oauth_token=/)
      expect(url).to match(/oauth_callback=/)
    end

    it "includes only oauth_token when no params provided" do
      url = request_token.authorize_url(nil)
      expect(url).to be_a(String)
      expect(url).to match(/\?oauth_token=/)

      url2 = request_token.authorize_url
      expect(url2).to be_a(String)
      expect(url2).to match(/\?oauth_token=/)
    end

    it "returns nil when token is nil" do
      request_token.token = nil
      expect(request_token.authorize_url).to be_nil
    end
  end

  describe "authenticate_url" do
    it "includes oauth_token and additional params when provided" do
      url = request_token.authenticate_url(oauth_callback: "github.com")
      expect(url).to be_a(String)
      expect(url).to match(/oauth_token=/)
      expect(url).to match(/oauth_callback=/)
    end

    it "includes only oauth_token when no params provided" do
      url = request_token.authenticate_url(nil)
      expect(url).to be_a(String)
      expect(url).to match(/\?oauth_token=/)

      url2 = request_token.authenticate_url
      expect(url2).to be_a(String)
      expect(url2).to match(/\?oauth_token=/)
    end

    it "returns nil when token is nil" do
      request_token.token = nil
      expect(request_token.authenticate_url).to be_nil
    end
  end

  describe "private build_url (via stubbed subclass)" do
    class StubbedToken < OAuth::RequestToken
      def build_url_promoted(root_domain, params)
        build_url(root_domain, params)
      end
    end

    it "percent-encodes values and joins with ?" do
      token = StubbedToken.new(nil, nil, nil)
      expect(token).to respond_to(:build_url_promoted)
      url = token.build_url_promoted("http://github.com/oauth/authorize", {foo: "bar bar"})
      expect(url).to eq("http://github.com/oauth/authorize?foo=bar+bar")
    end
  end
end
