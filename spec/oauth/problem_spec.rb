# frozen_string_literal: true

require "spec_helper"

RSpec.describe OAuth::Problem do
  it "is an OAuth::Unauthorized" do
    expect(described_class.ancestors).to include(OAuth::Unauthorized)
  end

  describe "#initialize" do
    it "stores problem, request, and params" do
      request = double("request")
      problem = described_class.new("token_expired", request, {"oauth_problem" => "token_expired"})

      expect(problem.problem).to eq("token_expired")
      expect(problem.request).to eq(request)
      expect(problem.params).to eq({"oauth_problem" => "token_expired"})
    end

    it "defaults request to nil and params to an empty hash" do
      problem = described_class.new("token_expired")

      expect(problem.request).to be_nil
      expect(problem.params).to eq({})
    end
  end

  describe "#to_s" do
    it "returns the problem string, overriding Unauthorized#to_s" do
      problem = described_class.new("token_expired")
      expect(problem.to_s).to eq("token_expired")
    end
  end
end
