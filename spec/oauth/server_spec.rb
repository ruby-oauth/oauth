# frozen_string_literal: true

require "spec_helper"
require "oauth/server"

RSpec.describe OAuth::Server do
  subject(:server) { described_class.new("http://test.com") }

  describe "defaults" do
    it "has default paths" do
      expect(server.request_token_path).to eq("/oauth/request_token")
      expect(server.authorize_path).to eq("/oauth/authorize")
      expect(server.access_token_path).to eq("/oauth/access_token")
    end

    it "builds default URLs from site + paths" do
      expect(server.request_token_url).to eq("http://test.com/oauth/request_token")
      expect(server.authorize_url).to eq("http://test.com/oauth/authorize")
      expect(server.access_token_url).to eq("http://test.com/oauth/access_token")
    end
  end

  describe "#create_consumer and #generate_consumer_credentials" do
    it "generates consumer credentials" do
      consumer = server.generate_consumer_credentials
      expect(consumer.key).to be_a(String)
      expect(consumer.secret).to be_a(String)
      expect(consumer.key).not_to be_empty
      expect(consumer.secret).not_to be_empty
    end

    it "creates a configured consumer with credentials" do
      consumer = server.create_consumer

      expect(consumer).to be_a(OAuth::Consumer)
      expect(consumer.key).to be_a(String)
      expect(consumer.secret).to be_a(String)
      expect(consumer.site).to eq("http://test.com")
      expect(consumer.request_token_path).to eq("/oauth/request_token")
      expect(consumer.authorize_path).to eq("/oauth/authorize")
      expect(consumer.access_token_path).to eq("/oauth/access_token")
      expect(consumer.request_token_url).to eq("http://test.com/oauth/request_token")
      expect(consumer.authorize_url).to eq("http://test.com/oauth/authorize")
      expect(consumer.access_token_url).to eq("http://test.com/oauth/access_token")
    end
  end
end
