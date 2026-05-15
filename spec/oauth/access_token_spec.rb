# frozen_string_literal: true

require "oauth/tokens/access_token"
require "oauth/consumer"

RSpec.describe OAuth::AccessToken do
  let(:fake_response) do
    {
      user_id: 5_734_758_743_895,
      oauth_token: "key",
      oauth_token_secret: "secret",
    }
  end

  let(:consumer) { OAuth::Consumer.new("key", "secret", {}) }

  describe "::from_hash" do
    it "creates an access token exposing response params" do
      access_token = described_class.from_hash(consumer, fake_response)
      expect(access_token).to be_a(described_class)
      expect(access_token).to respond_to(:params)
      expect(access_token.params[:user_id]).to eq(5_734_758_743_895)
    end
  end
end
