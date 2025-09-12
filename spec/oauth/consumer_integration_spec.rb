# frozen_string_literal: true

require "spec_helper"
require "net/http"

RSpec.describe "OAuth::Consumer integration" do
  let(:consumer) do
    OAuth::Consumer.new(
      "consumer_key_86cad9",
      "5888bf0345e5d237",
      {
        site: "http://blabla.bla",
        proxy: "http://user:password@proxy.bla:8080",
        request_token_path: "/oauth/example/request_token.php",
        access_token_path: "/oauth/example/access_token.php",
        authorize_path: "/oauth/example/authorize.php",
        scheme: :header,
        http_method: :get,
      },
    )
  end
  let(:token) { OAuth::ConsumerToken.new(consumer, "token_411a7f", "3196ffd991c8ebdb") }
  let(:request_uri) { URI.parse("http://example.com/test?key=value") }
  let(:request_parameters) { {"key" => "value"} }
  let(:nonce) { 225_579_211_881_198_842_005_988_698_334_675_835_446 }
  let(:timestamp) { "1199645624" }

  before do
    consumer.http = Net::HTTP.new(request_uri.host, request_uri.port)
  end

  describe "#sign! on Net::HTTP requests" do
    it "signs auth headers on GET requests deterministically" do
      request = Net::HTTP::Get.new("#{request_uri.path}?key=value")
      token.sign!(request, {nonce: nonce, timestamp: timestamp})

      expect(request.method).to eq("GET")
      expect(request.path).to eq("/test?key=value")
      expected = "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"1oO2izFav1GP4kEH2EskwXkCRFg%3D\", oauth_version=\"1.0\"".delete(",").split.sort
      actual = request["authorization"].delete(",").split.sort
      expect(actual).to eq(expected)
    end

    it "reflects signature_method set on consumer in Authorization header" do
      request = Net::HTTP::Get.new(request_uri.path)
      other_consumer = consumer.dup
      other_consumer.options[:signature_method] = "PLAINTEXT"
      other_token = OAuth::ConsumerToken.new(other_consumer, "token_411a7f", "3196ffd991c8ebdb")

      other_token.sign!(request, {nonce: nonce, timestamp: timestamp})

      expect(request["authorization"]).not_to match(/oauth_signature_method=\"HMAC-SHA1\"/)
      expect(request["authorization"]).to match(/oauth_signature_method=\"PLAINTEXT\"/)
    end

    it "affects signature_base_string when signature_method is PLAINTEXT" do
      other_consumer = consumer.dup
      other_consumer.options[:signature_method] = "PLAINTEXT"
      request = Net::HTTP::Get.new("/")

      signature_base_string = other_consumer.signature_base_string(request)
      expect(signature_base_string).not_to match(/HMAC-SHA1/)
      expect(signature_base_string).to eq("#{other_consumer.secret}&")
    end

    it "signs auth headers on POST requests" do
      request = Net::HTTP::Post.new(request_uri.path)
      request.set_form_data(request_parameters)
      token.sign!(request, {nonce: nonce, timestamp: timestamp})

      expect(request.method).to eq("POST")
      expect(request.path).to eq("/test")
      expect(request.body).to eq("key=value")
      expected = "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"26g7wHTtNO6ZWJaLltcueppHYiI%3D\", oauth_version=\"1.0\"".delete(",").split.sort
      actual = request["authorization"].delete(",").split.sort
      expect(actual).to eq(expected)
    end

    it "can sign POST params with scheme body" do
      request = Net::HTTP::Post.new(request_uri.path)
      request.set_form_data(request_parameters)
      token.sign!(request, {scheme: "body", nonce: nonce, timestamp: timestamp})

      expect(request.method).to eq("POST")
      expect(request.path).to eq("/test")
      joined = request.body.split("&").sort.join("&")
      expect(joined).to match(%r{key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=26g7wHTtNO6ZWJaLltcueppHYiI%3[Dd]&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0})
      expect(request["authorization"]).to be_nil
    end
  end

  describe "::create_signed_request" do
    it "uses auth headers on GET" do
      request = consumer.create_signed_request(
        :get,
        "#{request_uri.path}?key=value",
        token,
        {nonce: nonce, timestamp: timestamp},
        request_parameters,
      )

      expect(request.method).to eq("GET")
      expect(request.path).to eq("/test?key=value")
      expected = "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"1oO2izFav1GP4kEH2EskwXkCRFg%3D\", oauth_version=\"1.0\"".delete(",").split.sort
      actual = request["authorization"].delete(",").split.sort
      expect(actual).to eq(expected)
    end

    it "uses auth headers on POST" do
      request = consumer.create_signed_request(
        :post,
        request_uri.path,
        token,
        {nonce: nonce, timestamp: timestamp},
        request_parameters,
        {},
      )

      expect(request.method).to eq("POST")
      expect(request.path).to eq("/test")
      expect(request.body).to eq("key=value")
      expected = "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"26g7wHTtNO6ZWJaLltcueppHYiI%3D\", oauth_version=\"1.0\"".delete(",").split.sort
      actual = request["authorization"].delete(",").split.sort
      expect(actual).to eq(expected)
    end

    it "can sign POST params with scheme body" do
      request = consumer.create_signed_request(
        :post,
        request_uri.path,
        token,
        {scheme: "body", nonce: nonce, timestamp: timestamp},
        request_parameters,
        {},
      )

      expect(request.method).to eq("POST")
      expect(request.path).to eq("/test")
      joined = request.body.split("&").sort.join("&")
      expect(joined).to match(%r{key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=26g7wHTtNO6ZWJaLltcueppHYiI%3[Dd]&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0})
      expect(request["authorization"]).to be_nil
    end
  end

  describe "integration against term.ie example endpoints", :vcr do
    before do
      # Stub classic term.ie endpoints used by historical oauth tests
      # Request token
      stub_request(:any, "http://term.ie/oauth/example/request_token.php")
        .to_return(status: 200, body: "oauth_token=requestkey&oauth_token_secret=requestsecret")
      # Access token
      stub_request(:any, "http://term.ie/oauth/example/access_token.php")
        .to_return(status: 200, body: "oauth_token=accesskey&oauth_token_secret=accesssecret")
      # Echo API (GET)
      stub_request(:get, %r{http://term\.ie/oauth/example/echo_api\.php\?ok=hello&test=this})
        .to_return(status: 200, body: "ok=hello&test=this")
      # Echo API (POST)
      stub_request(:post, "http://term.ie/oauth/example/echo_api.php")
        .with(body: {"ok" => "hello", "test" => "this"})
        .to_return(status: 200, body: "ok=hello&test=this")
    end

    it "can perform a full token dance and call a protected resource" do
      consumer2 = OAuth::Consumer.new(
        "key",
        "secret",
        {
          site: "http://term.ie",
          request_token_path: "/oauth/example/request_token.php",
          access_token_path: "/oauth/example/access_token.php",
          authorize_path: "/oauth/example/authorize.php",
        },
      )

      expect(consumer2.request_token_url).to eq("http://term.ie/oauth/example/request_token.php")
      expect(consumer2.access_token_url).to eq("http://term.ie/oauth/example/access_token.php")

      expect(consumer2.request_token_url?).to be(false)
      expect(consumer2.access_token_url?).to be(false)
      expect(consumer2.authorize_url?).to be(false)

      request_token = consumer2.get_request_token
      expect(request_token.token).to eq("requestkey")
      expect(request_token.secret).to eq("requestsecret")
      expect(request_token.authorize_url).to eq("http://term.ie/oauth/example/authorize.php?oauth_token=requestkey")

      access_token = request_token.get_access_token
      expect(access_token.token).to eq("accesskey")
      expect(access_token.secret).to eq("accesssecret")

      response = access_token.get("/oauth/example/echo_api.php?ok=hello&test=this")
      expect(response.code).to eq("200")
      expect(response.body).to eq("ok=hello&test=this")

      response = access_token.post("/oauth/example/echo_api.php", {"ok" => "hello", "test" => "this"})
      expect(response.code).to eq("200")
      expect(response.body).to eq("ok=hello&test=this")
    end

    it "builds correct signature base string for request token" do
      consumer2 = OAuth::Consumer.new(
        "key",
        "secret",
        {
          site: "http://term.ie",
          request_token_path: "/oauth/example/request_token.php",
          access_token_path: "/oauth/example/access_token.php",
          authorize_path: "/oauth/example/authorize.php",
          scheme: :header,
        },
      )
      options = {nonce: "nonce", timestamp: Time.now.to_i.to_s}

      request = Net::HTTP::Get.new("/oauth/example/request_token.php")
      signature_base_string = consumer2.signature_base_string(request, nil, options)

      expect(signature_base_string).to eq(
        "GET&http%3A%2F%2Fterm.ie%2Foauth%2Fexample%2Frequest_token.php&oauth_consumer_key%3Dkey%26oauth_nonce%3D#{options[:nonce]}%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D#{options[:timestamp]}%26oauth_version%3D1.0",
      )

      consumer2.sign!(request, nil, options)
      expect(request.method).to eq("GET")
      expect(request.body).to be_nil

      response = consumer2.http.request(request)
      expect(response.code).to eq("200")
      expect(response.body).to eq("oauth_token=requestkey&oauth_token_secret=requestsecret")
    end
  end
end
