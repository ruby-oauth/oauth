# frozen_string_literal: true

RSpec.describe OAuth::Helper do
  describe "::parse_header" do
    it "parses a valid OAuth header" do
      header = 'OAuth realm="http://example.com/method", oauth_consumer_key="vince_clortho", oauth_token="token_value", oauth_signature_method="HMAC-SHA1", oauth_signature="signature_here", oauth_timestamp="1240004133", oauth_nonce="nonce", oauth_version="1.0" '

      params = described_class.parse_header(header)

      expect(params["realm"]).to eq("http://example.com/method")
      expect(params["oauth_consumer_key"]).to eq("vince_clortho")
      expect(params["oauth_token"]).to eq("token_value")
      expect(params["oauth_signature_method"]).to eq("HMAC-SHA1")
      expect(params["oauth_signature"]).to eq("signature_here")
      expect(params["oauth_timestamp"]).to eq("1240004133")
      expect(params["oauth_nonce"]).to eq("nonce")
      expect(params["oauth_version"]).to eq("1.0")
    end

    it "raises on ill-formed header" do
      expect { described_class.parse_header("OAuth garbage") }.to raise_error(OAuth::Problem)
    end

    it "raises on header with equals in a value" do
      header = 'OAuth realm="http://example.com/method", oauth_consumer_key="vince_clortho", oauth_token="token_value", oauth_signature_method="HMAC-SHA1", oauth_signature="signature_here_with_=", oauth_timestamp="1240004133", oauth_nonce="nonce", oauth_version="1.0" '
      expect { described_class.parse_header(header) }.to raise_error(OAuth::Problem)
    end

    it "parses header with ampersands between params" do
      header = 'OAuth realm="http://example.com/method"&oauth_consumer_key="vince_clortho"&oauth_token="token_value"&oauth_signature_method="HMAC-SHA1"&oauth_signature="signature_here"&oauth_timestamp="1240004133"&oauth_nonce="nonce"&oauth_version="1.0"'

      params = described_class.parse_header(header)

      expect(params["realm"]).to eq("http://example.com/method")
      expect(params["oauth_consumer_key"]).to eq("vince_clortho")
      expect(params["oauth_token"]).to eq("token_value")
      expect(params["oauth_signature_method"]).to eq("HMAC-SHA1")
      expect(params["oauth_signature"]).to eq("signature_here")
      expect(params["oauth_timestamp"]).to eq("1240004133")
      expect(params["oauth_nonce"]).to eq("nonce")
      expect(params["oauth_version"]).to eq("1.0")
    end
  end

  describe "::normalize" do
    it "normalizes nested params to query-string format" do
      params = {
        "oauth_nonce" => "nonce",
        "weight" => {value: "65"},
        "oauth_signature_method" => "HMAC-SHA1",
        "oauth_timestamp" => "1240004133",
        "oauth_consumer_key" => "vince_clortho",
        "oauth_token" => "token_value",
        "oauth_version" => "1.0",
      }

      expect(
        described_class.normalize(params),
      ).to eq("oauth_consumer_key=vince_clortho&oauth_nonce=nonce&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1240004133&oauth_token=token_value&oauth_version=1.0&weight%5Bvalue%5D=65")
    end

    it "normalizes with nested array of hashes" do
      params = {
        "oauth_nonce" => "nonce",
        "weight" => {value: "65"},
        "items" => [{"a" => 1}, {"b" => 2}],
        "oauth_signature_method" => "HMAC-SHA1",
        "oauth_timestamp" => "1240004133",
        "oauth_consumer_key" => "vince_clortho",
        "oauth_token" => "token_value",
        "oauth_version" => "1.0",
      }

      expect(
        described_class.normalize(params),
      ).to eq("items%5B%5D%5Ba%5D=1&items%5B%5D%5Bb%5D=2&oauth_consumer_key=vince_clortho&oauth_nonce=nonce&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1240004133&oauth_token=token_value&oauth_version=1.0&weight%5Bvalue%5D=65")
    end
  end

  describe "::normalize_nested_query" do
    it "handles empty and simple cases" do
      expect(described_class.normalize_nested_query({})).to be_empty
      expect(described_class.normalize_nested_query({foo: "bar"})).to eq(["foo=bar"])
      expect(described_class.normalize_nested_query({foo: "bar"}, "prefix")).to eq(["prefix%5Bfoo%5D=bar"])
    end

    it "handles nested hash with ordering" do
      expect(
        described_class.normalize_nested_query({user: {twitter_id: 123, date: "2011-10-05", age: 12}}, "prefix"),
      ).to eq([
        "prefix%5Buser%5D%5Bage%5D=12",
        "prefix%5Buser%5D%5Bdate%5D=2011-10-05",
        "prefix%5Buser%5D%5Btwitter_id%5D=123",
      ])
    end
  end
end
