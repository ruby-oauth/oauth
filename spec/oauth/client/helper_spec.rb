# frozen_string_literal: true

require "spec_helper"
require "net/http"
require "oauth/client/helper"

RSpec.describe OAuth::Client::Helper do
  subject(:helper) { described_class.new(request, base_options) }

  let(:consumer) { OAuth::Consumer.new("consumer_key_86cad9", "5888bf0345e5d237") }
  let(:token) { OAuth::Token.new("token_411a7f", "3196ffd991c8ebdb") }
  let(:uri) { URI.parse("http://example.com/test?key=value") }
  let(:request) { Net::HTTP::Get.new("#{uri.path}?key=value") }
  let(:nonce) { 225_579_211_881_198_842_005_988_698_334_675_835_446 }
  let(:timestamp) { "1199645624" }
  let(:base_options) do
    {
      consumer: consumer,
      token: token,
      request_uri: uri.to_s,
      nonce: nonce,
      timestamp: timestamp
    }
  end

  describe "#initialize" do
    it "defaults signature_method to HMAC-SHA1 when not provided" do
      expect(helper.options[:signature_method]).to eq("HMAC-SHA1")
    end

    it "keeps an explicitly provided signature_method" do
      explicit = described_class.new(request, base_options.merge(signature_method: "PLAINTEXT"))
      expect(explicit.options[:signature_method]).to eq("PLAINTEXT")
    end
  end

  describe "#nonce" do
    it "memoizes the provided nonce into options" do
      expect(helper.nonce).to eq(nonce)
      expect(helper.options[:nonce]).to eq(nonce)
    end

    it "generates and memoizes a nonce when none is provided" do
      fresh = described_class.new(request, base_options.reject { |k, _| k == :nonce })
      generated = fresh.nonce
      expect(generated).not_to be_nil
      expect(fresh.nonce).to eq(generated)
    end
  end

  describe "#timestamp" do
    it "memoizes the provided timestamp into options" do
      expect(helper.timestamp).to eq(timestamp)
      expect(helper.options[:timestamp]).to eq(timestamp)
    end

    it "generates and memoizes a timestamp when none is provided" do
      fresh = described_class.new(request, base_options.reject { |k, _| k == :timestamp })
      generated = fresh.timestamp
      expect(generated).not_to be_nil
      expect(fresh.timestamp).to eq(generated)
    end
  end

  describe "#oauth_parameters" do
    it "includes the core OAuth parameters" do
      params = helper.oauth_parameters
      expect(params["oauth_consumer_key"]).to eq("consumer_key_86cad9")
      expect(params["oauth_token"]).to eq("token_411a7f")
      expect(params["oauth_signature_method"]).to eq("HMAC-SHA1")
      expect(params["oauth_nonce"]).to eq(nonce)
      expect(params["oauth_timestamp"]).to eq(timestamp)
      expect(params["oauth_version"]).to eq("1.0")
    end

    it "omits empty-valued parameters by default" do
      params = helper.oauth_parameters
      expect(params).not_to have_key("oauth_verifier")
      expect(params).not_to have_key("oauth_session_handle")
      expect(params).not_to have_key("oauth_body_hash")
      expect(params).not_to have_key("oauth_callback")
    end

    it "keeps every empty-valued parameter when allow_empty_params is true" do
      with_flag = described_class.new(request, base_options.merge(allow_empty_params: true))
      params = with_flag.oauth_parameters
      expect(params).to have_key("oauth_verifier")
      expect(params).to have_key("oauth_session_handle")
    end

    it "keeps only the named parameter when allow_empty_params is an array" do
      with_array = described_class.new(request, base_options.merge(allow_empty_params: ["oauth_verifier"]))
      params = with_array.oauth_parameters
      expect(params).to have_key("oauth_verifier")
      expect(params).not_to have_key("oauth_session_handle")
    end

    it "keeps only the named parameter when allow_empty_params is a single string" do
      with_string = described_class.new(request, base_options.merge(allow_empty_params: "oauth_verifier"))
      params = with_string.oauth_parameters
      expect(params).to have_key("oauth_verifier")
      expect(params).not_to have_key("oauth_session_handle")
    end

    it "omits every empty-valued parameter when allow_empty_params is explicitly false" do
      with_false = described_class.new(request, base_options.merge(allow_empty_params: false))
      params = with_false.oauth_parameters
      expect(params).not_to have_key("oauth_verifier")
    end
  end

  describe "#token_request?" do
    it "is false by default" do
      expect(helper.token_request?).to be(false)
    end

    it "is true only when options[:token_request] is exactly true" do
      token_request = described_class.new(request, base_options.merge(token_request: true))
      expect(token_request.token_request?).to be(true)

      truthy_but_not_true = described_class.new(request, base_options.merge(token_request: "yes"))
      expect(truthy_but_not_true.token_request?).to be(false)
    end
  end

  describe "#hash_body" do
    it "computes and memoizes a body hash into options[:body_hash]" do
      expect(helper.options[:body_hash]).to be_nil
      hash = helper.hash_body
      expect(hash).not_to be_nil
      expect(helper.options[:body_hash]).to eq(hash)
    end
  end

  describe "#amend_user_agent_header" do
    it "sets a fresh User-Agent header when none is present" do
      headers = {}
      helper.amend_user_agent_header(headers)
      expect(headers["User-Agent"]).to eq("OAuth gem v#{OAuth::Version::VERSION}")
    end

    it "treats a bare Ruby default User-Agent the same as absent" do
      headers = {"User-Agent" => "Ruby"}
      helper.amend_user_agent_header(headers)
      expect(headers["User-Agent"]).to eq("OAuth gem v#{OAuth::Version::VERSION}")
    end

    it "appends to an existing, non-default User-Agent header instead of replacing it" do
      headers = {"User-Agent" => "MyApp/1.0"}
      helper.amend_user_agent_header(headers)
      expect(headers["User-Agent"]).to eq("MyApp/1.0 (OAuth gem v#{OAuth::Version::VERSION})")
    end
  end

  describe "#header" do
    it "produces a well-formed OAuth Authorization header with sorted parameters" do
      header = helper.header
      expect(header).to start_with("OAuth ")
      expect(header).to include("oauth_signature=")
      expect(header).to include("oauth_consumer_key=\"consumer_key_86cad9\"")
      keys = header.sub(/^OAuth /, "").split(", ").map { |pair| pair.split("=").first }
      expect(keys).to eq(keys.sort)
    end

    it "prefixes the header with realm when options[:realm] is set" do
      with_realm = described_class.new(request, base_options.merge(realm: "http://example.com"))
      expect(with_realm.header).to start_with("OAuth realm=\"http://example.com\", ")
    end
  end

  describe "#parameters" do
    it "delegates to the request proxy's parameters" do
      expect(helper.parameters).to eq(OAuth::RequestProxy.proxy(request).parameters)
    end
  end

  describe "#parameters_with_oauth" do
    it "merges the OAuth parameters with the request's own parameters" do
      merged = helper.parameters_with_oauth
      expect(merged["oauth_consumer_key"]).to eq("consumer_key_86cad9")
      expect(merged["key"]).to eq(helper.parameters["key"])
    end
  end
end
