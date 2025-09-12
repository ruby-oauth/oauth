# frozen_string_literal: true

RSpec.describe "Backwards compatibility" do
  it "aliases OAuth::CLI to OAuth::TTY::CLI" do
    require "oauth/cli"
    expect(OAuth::CLI).to be(OAuth::TTY::CLI)
  end
end
