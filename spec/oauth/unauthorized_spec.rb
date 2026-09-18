# frozen_string_literal: true

require "spec_helper"

RSpec.describe OAuth::Unauthorized do
  it "is an OAuth::Error" do
    expect(described_class.ancestors).to include(OAuth::Error)
  end

  describe "#request" do
    it "defaults to nil" do
      expect(described_class.new.request).to be_nil
    end

    it "returns the request it was constructed with" do
      request = double("request")
      expect(described_class.new(request).request).to eq(request)
    end
  end

  describe "#to_s" do
    it "returns a generic message when no request is present" do
      expect(described_class.new.to_s).to eq("401 Unauthorized")
    end

    it "returns the request's code and message when a request is present" do
      request = double("request", code: "401", message: "Unauthorized")
      expect(described_class.new(request).to_s).to eq("401 Unauthorized")
    end

    it "reflects whatever code/message the underlying request reports" do
      request = double("request", code: "419", message: "Session Expired")
      expect(described_class.new(request).to_s).to eq("419 Session Expired")
    end
  end
end
