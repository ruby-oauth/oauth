# frozen_string_literal: true

require "oauth/token"

RSpec.describe OAuth::Token do
  describe "#initialize" do
    it "assigns token and secret" do
      token = described_class.new("xyz", "123")
      expect(token.token).to eq("xyz")
      expect(token.secret).to eq("123")
    end
  end
end
