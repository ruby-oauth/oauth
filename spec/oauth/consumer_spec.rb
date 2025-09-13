# frozen_string_literal: true

require "stringio"

RSpec.describe OAuth::Consumer do
  let(:consumer_key) { "consumer_key_86cad9" }
  let(:consumer_secret) { "5888bf0345e5d237" }

  describe "#initialize and attribute defaults" do
    it "sets provided attributes and defaults" do
      consumer = described_class.new(
        consumer_key,
        consumer_secret,
        site: "http://blabla.bla",
        proxy: "http://user:password@proxy.bla:8080",
        request_token_path: "/oauth/example/request_token.php",
        access_token_path: "/oauth/example/access_token.php",
        authorize_path: "/oauth/example/authorize.php",
        scheme: :header,
        http_method: :get,
      )

      expect(consumer.key).to eq(consumer_key)
      expect(consumer.secret).to eq(consumer_secret)
      expect(consumer.site).to eq("http://blabla.bla")
      expect(consumer.proxy).to eq("http://user:password@proxy.bla:8080")
      expect(consumer.request_token_path).to eq("/oauth/example/request_token.php")
      expect(consumer.access_token_path).to eq("/oauth/example/access_token.php")
      expect(consumer.request_token_url).to eq("http://blabla.bla/oauth/example/request_token.php")
      expect(consumer.access_token_url).to eq("http://blabla.bla/oauth/example/access_token.php")
      expect(consumer.authorize_url).to eq("http://blabla.bla/oauth/example/authorize.php")
      expect(consumer.scheme).to eq(:header)
      expect(consumer.http_method).to eq(:get)
      expect(consumer.debug_output).to be_nil
    end

    it "applies sensible defaults when only site given" do
      consumer = described_class.new("key", "secret", site: "http://twitter.com")

      expect(consumer.key).to eq("key")
      expect(consumer.secret).to eq("secret")
      expect(consumer.site).to eq("http://twitter.com")
      expect(consumer.proxy).to be_nil
      expect(consumer.request_token_path).to eq("/oauth/request_token")
      expect(consumer.access_token_path).to eq("/oauth/access_token")
      expect(consumer.request_token_url).to eq("http://twitter.com/oauth/request_token")
      expect(consumer.access_token_url).to eq("http://twitter.com/oauth/access_token")
      expect(consumer.authorize_url).to eq("http://twitter.com/oauth/authorize")
      expect(consumer.scheme).to eq(:header)
      expect(consumer.http_method).to eq(:post)
      expect(consumer.debug_output).to be_nil
    end

    it "treats debug_output: true as $stdout" do
      consumer = described_class.new("key", "secret", debug_output: true)
      expect(consumer.debug_output).to be($stdout)
    end

    it "accepts an IO for debug_output" do
      io = StringIO.new
      consumer = described_class.new("key", "secret", debug_output: io)
      expect(consumer.debug_output).to be(io)
    end

    it "allows overriding full URLs without appending site path" do
      consumer = described_class.new(
        "key",
        "secret",
        site: "http://twitter.com",
        request_token_url: "http://oauth.twitter.com/request_token",
        access_token_url: "http://oauth.twitter.com/access_token",
        authorize_url: "http://site.twitter.com/authorize",
      )

      expect(consumer.request_token_path).to eq("/oauth/request_token")
      expect(consumer.access_token_path).to eq("/oauth/access_token")
      expect(consumer.request_token_url).to eq("http://oauth.twitter.com/request_token")
      expect(consumer.access_token_url).to eq("http://oauth.twitter.com/access_token")
      expect(consumer.authorize_url).to eq("http://site.twitter.com/authorize")
      expect(consumer.http_method).to eq(:post)
      expect(consumer.scheme).to eq(:header)
    end
  end

  describe "request URL path joining" do
    it "does not duplicate path when site has no path component" do
      consumer = described_class.new("key", "secret", site: "http://twitter.com")

      # We don't need to actually perform the HTTP call; we just want to verify
      # that the request path sent to Net::HTTP::Get.new is correct.
      request_double = instance_double("Net::HTTP::Get").as_null_object
      expect(Net::HTTP::Get).to receive(:new).with("/people", kind_of(Hash)).and_return(request_double)

      http_double = double("http", request: double("response", to_hash: {}), address: "identi.ca")
      expect(consumer).to receive(:create_http).and_return(http_double)

      consumer.request(:get, "/people", nil, {})
    end

    it "prefixes site path when site includes a path" do
      consumer = described_class.new("key", "secret", site: "http://identi.ca/api")

      request_double = instance_double("Net::HTTP::Get").as_null_object
      expect(Net::HTTP::Get).to receive(:new).with("/api/people", kind_of(Hash)).and_return(request_double)

      http_double = double("http", request: double("response", to_hash: {}), address: "identi.ca")
      expect(consumer).to receive(:create_http).and_return(http_double)

      consumer.request(:get, "/people", nil, {})
    end
  end

  describe "signed requests" do
    it "form-encodes nested params for POST" do
      consumer = described_class.new("key", "secret", site: "http://twitter.com")

      request = consumer.create_signed_request(
        :post,
        "/people",
        nil,
        {},
        {key: {subkey: "value"}},
      )

      expect(request.body).to eq("key%5Bsubkey%5D=value")
      expect(request.content_type).to eq("application/x-www-form-urlencoded")
    end
  end

  describe "SSL verify toggle" do
    it "sets VERIFY_NONE when no_verify: true" do
      consumer = described_class.new(
        "key",
        "secret",
        site: "https://api.mysite.co.nz/v1",
        request_token_url: "https://authentication.mysite.co.nz/Oauth/RequestToken",
        no_verify: true,
      )

      stub_request(:post, "https://authentication.mysite.co.nz/Oauth/RequestToken").to_return(body: "success", status: 200)

      # Any Net::HTTP instance created during get_request_token should get verify_mode set
      http_instance = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_instance)
      allow(http_instance).to receive(:use_ssl=)
      allow(http_instance).to receive(:ca_file=)
      allow(http_instance).to receive(:verify_depth=)
      allow(http_instance).to receive(:read_timeout=)
      allow(http_instance).to receive(:open_timeout=)
      allow(http_instance).to receive(:ssl_version=)
      allow(http_instance).to receive(:cert=)
      allow(http_instance).to receive(:key=)
      allow(http_instance).to receive(:set_debug_output)
      allow(http_instance).to receive(:address).and_return("authentication.mysite.co.nz")
      expect(http_instance).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
      allow(http_instance).to receive(:request).and_return(double(to_hash: {}, code: "200", body: ""))

      # The request inside get_request_token is not important beyond hitting the code path
      expect { consumer.get_request_token }.not_to raise_error
    end

    it "sets VERIFY_PEER when no_verify: false" do
      consumer = described_class.new(
        "key",
        "secret",
        site: "https://api.mysite.co.nz/v1",
        request_token_url: "https://authentication.mysite.co.nz/Oauth/RequestToken",
        no_verify: false,
      )

      stub_request(:post, "https://authentication.mysite.co.nz/Oauth/RequestToken").to_return(body: "success", status: 200)

      http_instance = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_instance)
      allow(http_instance).to receive(:use_ssl=)
      allow(http_instance).to receive(:ca_file=)
      allow(http_instance).to receive(:verify_depth=)
      allow(http_instance).to receive(:read_timeout=)
      allow(http_instance).to receive(:open_timeout=)
      allow(http_instance).to receive(:ssl_version=)
      allow(http_instance).to receive(:cert=)
      allow(http_instance).to receive(:key=)
      allow(http_instance).to receive(:set_debug_output)
      allow(http_instance).to receive(:address).and_return("authentication.mysite.co.nz")
      expect(http_instance).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
      allow(http_instance).to receive(:request).and_return(double(to_hash: {}, code: "200", body: ""))

      expect { consumer.get_request_token }.not_to raise_error
    end

    it "respects full request_token_url without prefixing site" do
      consumer = described_class.new(
        "key",
        "secret",
        site: "https://api.mysite.co.nz/v1",
        request_token_url: "https://authentication.mysite.co.nz/Oauth/RequestToken",
      )

      stub_request(:post, "https://authentication.mysite.co.nz/Oauth/RequestToken").to_return(body: "success", status: 200)

      http_instance = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_instance)
      allow(http_instance).to receive(:use_ssl=)
      allow(http_instance).to receive(:ca_file=)
      allow(http_instance).to receive(:verify_depth=)
      allow(http_instance).to receive(:read_timeout=)
      allow(http_instance).to receive(:open_timeout=)
      allow(http_instance).to receive(:ssl_version=)
      allow(http_instance).to receive(:cert=)
      allow(http_instance).to receive(:key=)
      allow(http_instance).to receive(:set_debug_output)
      allow(http_instance).to receive(:address).and_return("authentication.mysite.co.nz")
      allow(http_instance).to receive(:verify_mode=)
      allow(http_instance).to receive(:request).and_return(double(to_hash: {}, code: "200", body: ""))

      expect { consumer.get_request_token }.not_to raise_error
    end
  end
end
