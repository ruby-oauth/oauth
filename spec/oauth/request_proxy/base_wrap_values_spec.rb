# frozen_string_literal: true

require "oauth/request_proxy/base"

RSpec.describe OAuth::RequestProxy::Base do
  it "wraps scalar values into arrays, preserves arrays, preserves nil, and returns {} for nil input" do
    # Create an anonymous subclass to expose the protected method for testing
    dummy_cls = Class.new(OAuth::RequestProxy::Base) do
      public :wrap_values
    end

    dp = dummy_cls.new(Object.new)

    expect(dp.wrap_values(nil)).to eq({})

    input = {"a" => "1", "b" => ["x"], "c" => nil}
    out = dp.wrap_values(input)

    expect(out["a"]).to eq(["1"]) # scalar -> array
    expect(out["b"]).to eq(["x"]) # array unchanged
    expect(out["c"]).to be_nil     # nil preserved
  end
end
