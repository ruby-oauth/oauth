# frozen_string_literal: true

begin
  require "eventmachine"
  require "em-http-request"

  RSpec.describe "EventMachine HTTP client integration" do
    it "is skipped until em-http-request is available" do
      skip("em-http-request not exercised in this environment")
    end
  end
rescue LoadError
  RSpec.describe "EventMachine HTTP client integration" do
    it "is pending because em-http-request is not installed" do
      pending("em-http-request not installed")
      raise "unreachable"
    end
  end
end
