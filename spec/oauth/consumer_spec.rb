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

    it "redacts secret from inspect" do
      consumer = described_class.new("key", "super-secret", site: "http://twitter.com")

      expect(consumer.inspect).to include("@secret=[FILTERED]")
      expect(consumer.inspect).not_to include("super-secret")
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
      request_double = instance_double(Net::HTTP::Get).as_null_object
      allow(Net::HTTP::Get).to receive(:new).with("/people", kind_of(Hash)).and_return(request_double)

      http_double = double("http", request: double("response", to_hash: {}), address: "identi.ca")
      allow(consumer).to receive(:create_http).and_return(http_double)

      consumer.request(:get, "/people", nil, {})

      expect(Net::HTTP::Get).to have_received(:new).with("/people", kind_of(Hash))
      expect(consumer).to have_received(:create_http)
    end

    it "prefixes site path when site includes a path" do
      consumer = described_class.new("key", "secret", site: "http://identi.ca/api")

      request_double = instance_double(Net::HTTP::Get).as_null_object
      allow(Net::HTTP::Get).to receive(:new).with("/api/people", kind_of(Hash)).and_return(request_double)

      http_double = double("http", request: double("response", to_hash: {}), address: "identi.ca")
      allow(consumer).to receive(:create_http).and_return(http_double)

      consumer.request(:get, "/people", nil, {})

      expect(Net::HTTP::Get).to have_received(:new).with("/api/people", kind_of(Hash))
      expect(consumer).to have_received(:create_http)
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

  describe "#token_request redirects" do
    let(:redirect_error) { Class.new(StandardError) }
    let(:response_class) do
      error_class = redirect_error

      Class.new do
        attr_reader :code, :body

        define_method(:initialize) do |code, body = "", headers = {}|
          @code = code
          @body = body
          @headers = headers
        end

        define_method(:[]) do |key|
          @headers[key] || @headers[key.to_s] || @headers[key.to_s.downcase]
        end

        define_method(:to_hash) do
          {}
        end

        define_method(:error!) do
          raise error_class, "redirect refused"
        end
      end
    end

    def token_response(response_class, code, body = "", headers = {})
      response_class.new(code, body, headers)
    end

    def stub_token_request_sequence(consumer, responses, seen_paths, seen_options = [])
      allow(consumer).to receive(:request) do |_http_method, path, _token, request_options, *_arguments|
        seen_paths << path
        seen_options << request_options
        responses.shift
      end
    end

    it "follows same-origin absolute redirects without mutating the consumer site" do
      consumer = described_class.new("key", "secret", site: "http://twitter.com")
      seen_paths = []
      seen_options = []
      responses = [
        token_response(response_class, "302", "", "location" => "http://twitter.com/oauth/next?step=1"),
        token_response(response_class, "200", "oauth_token=requestkey&oauth_token_secret=requestsecret"),
      ]
      stub_token_request_sequence(consumer, responses, seen_paths, seen_options)

      token = consumer.token_request(:post, "/oauth/request_token", nil, token_request_max_redirects: 2)

      expect(token[:oauth_token]).to eq("requestkey")
      expect(seen_paths).to eq(["/oauth/request_token", "/oauth/next?step=1"])
      expect(seen_options).to all(include(token_request: true))
      expect(seen_options).not_to include(include(:token_request_redirect_count))
      expect(seen_options).not_to include(include(:token_request_max_redirects))
      expect(consumer.site).to eq("http://twitter.com")
    end

    it "resolves relative redirects against the current token request path" do
      consumer = described_class.new("key", "secret", site: "https://api.example.com")
      seen_paths = []
      responses = [
        token_response(response_class, "302", "", "location" => "continued"),
        token_response(response_class, "200", "oauth_token=requestkey&oauth_token_secret=requestsecret"),
      ]
      stub_token_request_sequence(consumer, responses, seen_paths)

      consumer.token_request(:post, "/oauth/request_token", nil, {})

      expect(seen_paths).to eq(["/oauth/request_token", "/oauth/continued"])
    end

    it "rejects absolute cross-origin redirects by default" do
      consumer = described_class.new("key", "secret", site: "https://api.example.com")
      seen_paths = []
      responses = [
        token_response(response_class, "302", "", "location" => "https://evil.example/oauth/request_token"),
      ]
      stub_token_request_sequence(consumer, responses, seen_paths)

      expect { consumer.token_request(:post, "/oauth/request_token", nil, {}) }.to raise_error(redirect_error)
      expect(seen_paths).to eq(["/oauth/request_token"])
      expect(consumer.site).to eq("https://api.example.com")
    end

    it "rejects protocol-relative cross-origin redirects by default" do
      consumer = described_class.new("key", "secret", site: "https://api.example.com")
      seen_paths = []
      responses = [
        token_response(response_class, "302", "", "location" => "//evil.example/oauth/request_token"),
      ]
      stub_token_request_sequence(consumer, responses, seen_paths)

      expect { consumer.token_request(:post, "/oauth/request_token", nil, {}) }.to raise_error(redirect_error)
      expect(seen_paths).to eq(["/oauth/request_token"])
    end

    it "follows explicit opt-in cross-origin redirects without mutating the consumer site" do
      consumer = described_class.new("key", "secret", site: "https://api.example.com")
      seen_paths = []
      responses = [
        token_response(response_class, "302", "", "location" => "https://issuer.example/oauth/request_token?via=redirect"),
        token_response(response_class, "200", "oauth_token=requestkey&oauth_token_secret=requestsecret"),
      ]
      stub_token_request_sequence(consumer, responses, seen_paths)

      consumer.token_request(:post, "/oauth/request_token", nil, token_request_cross_origin_redirects: true)

      expect(seen_paths).to eq(["/oauth/request_token", "https://issuer.example/oauth/request_token?via=redirect"])
      expect(consumer.site).to eq("https://api.example.com")
    end

    it "rejects redirect chains longer than the configured maximum" do
      consumer = described_class.new("key", "secret", site: "https://api.example.com")
      seen_paths = []
      responses = [
        token_response(response_class, "302", "", "location" => "/oauth/first"),
        token_response(response_class, "302", "", "location" => "/oauth/second"),
      ]
      stub_token_request_sequence(consumer, responses, seen_paths)

      expect do
        consumer.token_request(:post, "/oauth/request_token", nil, token_request_max_redirects: 1)
      end.to raise_error(redirect_error)
      expect(seen_paths).to eq(["/oauth/request_token", "/oauth/first"])
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
      allow(http_instance).to receive_messages(
        address: "authentication.mysite.co.nz",
        request: double(to_hash: {}, code: "200", body: ""),
      )
      expect(http_instance).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

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
      allow(http_instance).to receive_messages(
        address: "authentication.mysite.co.nz",
        request: double(to_hash: {}, code: "200", body: ""),
      )
      expect(http_instance).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)

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
      allow(http_instance).to receive_messages(
        :verify_mode= => nil,
        :address => "authentication.mysite.co.nz",
        :request => double(to_hash: {}, code: "200", body: ""),
      )

      expect { consumer.get_request_token }.not_to raise_error
    end
  end
end
