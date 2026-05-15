# frozen_string_literal: true

require "oauth/token"

RSpec.describe OAuth::Token do
  describe "#initialize" do
    it "assigns token and secret" do
      token = described_class.new("xyz", "123")
      expect(token.token).to eq("xyz")
      expect(token.secret).to eq("123")
    end

    it "redacts token and secret from inspect" do
      token = described_class.new("xyz", "123")

      expect(token.inspect).to include("@token=[FILTERED]")
      expect(token.inspect).to include("@secret=[FILTERED]")
      expect(token.inspect).not_to include("xyz")
      expect(token.inspect).not_to include("123")
    end
  end
end
