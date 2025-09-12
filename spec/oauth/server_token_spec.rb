# frozen_string_literal: true

require "spec_helper"
require "oauth/tokens/server_token"

RSpec.describe OAuth::ServerToken do
  describe "initialization" do
    it "initializes with generated token and secret" do
      allow_any_instance_of(described_class).to receive(:generate_key).with(16).and_return("TOKEN16")
      allow_any_instance_of(described_class).to receive(:generate_key).with(no_args).and_return("SECRET32")

      st = described_class.new

      expect(st.token).to eq("TOKEN16")
      expect(st.secret).to eq("SECRET32")
    end

    it "defaults secret length to helper generate_key (no args)" do
      allow_any_instance_of(described_class).to receive(:generate_key).with(16).and_return("A" * 8)
      allow_any_instance_of(described_class).to receive(:generate_key).with(no_args).and_return("B" * 12)

      st = described_class.new

      expect(st.token).to eq("A" * 8)
      expect(st.secret).to eq("B" * 12)
    end
  end
end
