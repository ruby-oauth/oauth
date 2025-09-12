# frozen_string_literal: true

require "oauth/signature/base"
require "net/http"

RSpec.describe OAuth::Signature::Base do
  describe "#initialize" do
    it "requires at least one request argument" do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it "requires a valid request proxy object" do
      request = nil
      expect do
        described_class.new(request) do |_token|
          # no-op block
        end
      end.to raise_error(TypeError)
    end

    it "succeeds when the request proxy is valid" do
      raw_request = Net::HTTP::Get.new("/test")
      request = OAuth::RequestProxy.proxy(raw_request)

      # Should not raise
      expect do
        described_class.new(request) { |_token| }
      end.not_to raise_error
    end
  end
end
