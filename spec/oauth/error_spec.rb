# frozen_string_literal: true

require "spec_helper"

RSpec.describe OAuth::Error do
  it "is a StandardError" do
    expect(described_class.ancestors).to include(StandardError)
  end

  it "can be raised and rescued with a custom message" do
    expect { raise described_class, "went wrong" }.to raise_error(described_class, "went wrong")
  end
end
