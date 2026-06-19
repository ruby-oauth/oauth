# frozen_string_literal: true

require "open3"
require "rbconfig"

RSpec.describe "OAuth::AUTH_SANITIZER" do
  it "keeps auth-sanitizer constants isolated inside the OAuth namespace" do
    lib = File.expand_path("../../../lib", __dir__)
    spec = File.expand_path("..", __dir__)
    script = <<~RUBY
      $LOAD_PATH.unshift(#{lib.inspect})
      $LOAD_PATH.unshift(#{spec.inspect})
      require "rspec/core"
      require "spec_helper"
      abort "Auth was defined" if Object.const_defined?(:Auth, false)
      abort "AuthSanitizer was defined" if Object.const_defined?(:AuthSanitizer, false)
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script)

    expect(status).to be_success, "#{stdout}#{stderr}"
  end

  it "provides filtered attributes for OAuth objects" do
    expect(OAuth::Consumer.ancestors).to include(OAuth::AUTH_SANITIZER::FilteredAttributes)
    expect(OAuth::Token.ancestors).to include(OAuth::AUTH_SANITIZER::FilteredAttributes)
    expect(OAuth::Signature::Base.ancestors).to include(OAuth::AUTH_SANITIZER::FilteredAttributes)
  end
end
