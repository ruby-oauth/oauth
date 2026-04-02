# frozen_string_literal: true

require "oauth/request_proxy/base"

RSpec.describe OAuth::RequestProxy::Base do
  # Subclasses that use wrap_values (e.g. ActionControllerRequest,
  # ActionDispatchRequest) store all parameters as arrays. These specs
  # verify that every oauth_* accessor safely unwraps array values so
  # callers always receive a scalar string (or nil), regardless of whether
  # the parameter arrived as a scalar or a wrapped array.
  let(:proxy_class) do
    Class.new(OAuth::RequestProxy::Base) do
      attr_writer :params

      def parameters
        @params || {}
      end
    end
  end

  def proxy_with(params)
    proxy_class.new(Object.new).tap { |p| p.params = params }
  end

  shared_examples "scalar accessor" do |method, key|
    it "returns a scalar when the parameter is stored as a single-element array" do
      p = proxy_with(key => ["value"])
      expect(p.public_send(method)).to eq("value")
    end

    it "returns a scalar when the parameter is stored as a plain string" do
      p = proxy_with(key => "value")
      expect(p.public_send(method)).to eq("value")
    end

    it "returns nil when the parameter is absent" do
      p = proxy_with({})
      expect(p.public_send(method)).to be_nil
    end
  end

  include_examples "scalar accessor", :oauth_consumer_key,    "oauth_consumer_key"
  include_examples "scalar accessor", :oauth_nonce,           "oauth_nonce"
  include_examples "scalar accessor", :oauth_timestamp,       "oauth_timestamp"
  include_examples "scalar accessor", :oauth_token,           "oauth_token"
  include_examples "scalar accessor", :oauth_signature_method,"oauth_signature_method"
  include_examples "scalar accessor", :oauth_callback,        "oauth_callback"
  include_examples "scalar accessor", :oauth_verifier,        "oauth_verifier"
  include_examples "scalar accessor", :oauth_version,         "oauth_version"

  describe "#oauth_signature" do
    it "returns a scalar when the parameter is stored as a single-element array" do
      p = proxy_with("oauth_signature" => ["sig"])
      expect(p.oauth_signature).to eq("sig")
    end

    it "returns a scalar when the parameter is stored as a plain string" do
      p = proxy_with("oauth_signature" => "sig")
      expect(p.oauth_signature).to eq("sig")
    end

    it "returns an empty string when the parameter is absent" do
      p = proxy_with({})
      expect(p.oauth_signature).to eq("")
    end
  end
end
