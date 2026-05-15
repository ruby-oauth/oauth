# frozen_string_literal: true

require "spec_helper"
require "oauth/tokens/server_token"

RSpec.describe OAuth::ServerToken do
  let(:token_class) do
    Class.new(described_class) do
      def generate_key(size = 32)
        (size == 16) ? "TOKEN16" : "SECRET32"
      end
    end
  end

  describe "initialization" do
    it "initializes with generated token and secret" do
      st = token_class.new

      expect(st.token).to eq("TOKEN16")
      expect(st.secret).to eq("SECRET32")
    end

    it "defaults secret length to helper generate_key (no args)" do
      token_class = Class.new(described_class) do
        def generate_key(size = 32)
          (size == 16) ? ("A" * 8) : ("B" * 12)
        end
      end

      st = token_class.new

      expect(st.token).to eq("A" * 8)
      expect(st.secret).to eq("B" * 12)
    end
  end
end
