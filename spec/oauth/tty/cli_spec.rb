# frozen_string_literal: true

RSpec.describe OAuth::TTY::CLI do
  let(:stdout) { StringIO.new }
  let(:stdin) { StringIO.new }
  let(:stderr) { StringIO.new }

  def run_command(args = [])
    cmd = args.shift
    # Ensure isolated capture per run; clear any previous content on shared stdout
    stdout.truncate(0)
    stdout.rewind
    described_class.new(stdout, stdin, stderr, cmd, args).run
    stdout.rewind
    stdout.read
  end

  def parse(command)
    cli = described_class.new(stdout, stdin, stderr, command, [])
    cli.send(:parse_command, command)
  end

  describe "#parse_command" do
    it "parses dashed variants" do
      expect(parse("-v")).to eq("version")
      expect(parse("--version")).to eq("version")

      expect(parse("-h")).to eq("help")
      expect(parse("--help")).to eq("help")
      expect(parse("-H")).to eq("help")
      expect(parse("--HELP")).to eq("help")
    end

    it "parses default/unknown as help" do
      expect(parse("")).to eq("help")
      expect(parse(nil)).to eq("help")
      expect(parse("NotACommand")).to eq("help")
    end

    it "parses abbreviated lowercase commands" do
      expect(parse("h")).to eq("help")
      expect(parse("v")).to eq("version")
      expect(parse("q")).to eq("query")
      expect(parse("a")).to eq("authorize")
      expect(parse("s")).to eq("sign")
    end

    it "parses full lowercase commands" do
      expect(parse("help")).to eq("help")
      expect(parse("version")).to eq("version")
      expect(parse("query")).to eq("query")
      expect(parse("authorize")).to eq("authorize")
      expect(parse("sign")).to eq("sign")
    end

    it "parses abbreviated uppercase commands" do
      expect(parse("H")).to eq("help")
      expect(parse("V")).to eq("version")
      expect(parse("Q")).to eq("query")
      expect(parse("A")).to eq("authorize")
      expect(parse("S")).to eq("sign")
    end

    it "parses full uppercase commands" do
      expect(parse("HELP")).to eq("help")
      expect(parse("VERSION")).to eq("version")
      expect(parse("QUERY")).to eq("query")
      expect(parse("AUTHORIZE")).to eq("authorize")
      expect(parse("SIGN")).to eq("sign")
    end
  end

  describe "#run", :check_output do
    it "prints help when empty args" do
      out = run_command
      expect(out).to match(/Usage: /)
    end

    it "prints help" do
      out = run_command(%w[help])
      expect(out).to match(/Usage: /)
    end

    it "prints version" do
      out = run_command(%w[version])
      # Normalize whitespace per line so the spec is insensitive to indentation differences
      normalized = out.lines.map { |l| l.strip }
      expected = [
        "OAuth Gem #{OAuth::Version::VERSION}",
        "OAuth TTY Gem #{OAuth::TTY::Version::VERSION}"
      ]
      expect(normalized).to eq(expected)
    end

    it "prints help for query with no args" do
      out = run_command(%w[query])
      expect(out).to eq(help_output)
    end

    it "prints help for sign with no args" do
      out = run_command(%w[sign])
      expect(out).to eq(help_output)
    end

    it "prints help for authorize with no args" do
      out = run_command(%w[authorize])
      expect(out).to eq(help_output)
    end

    it "performs query and prints request/response" do
      consumer = instance_double("OAuth::Consumer")
      access_token = instance_double("OAuth::AccessToken")
      response = instance_double("Response", code: "!code!", message: "!message!", body: "!body!")

      allow(OAuth::Helper).to receive(:generate_key).and_return("GENERATE_KEY")
      allow(OAuth::Helper).to receive(:generate_timestamp).and_return("GENERATE_TIMESTAMP")

      expect(OAuth::Consumer).to receive(:new) do |key, secret, options|
        expect(key).to eq("oauth_consumer_key")
        expect(secret).to eq("oauth_consumer_secret")
        expect(options).to eq({scheme: :header})
        consumer
      end

      expect(OAuth::AccessToken).to receive(:new) do |c, token, secret|
        expect(c).to equal(consumer)
        expect(token).to eq("TOKEN")
        expect(secret).to eq("SECRET")
        access_token
      end

      expect(access_token).to receive(:request).with(:post, "http://example.com/oauth/url?oauth_consumer_key=oauth_consumer_key&oauth_nonce=GENERATE_KEY&oauth_timestamp=GENERATE_TIMESTAMP&oauth_token=TOKEN&oauth_signature_method=HMAC-SHA1&oauth_version=1.0").and_return(response)

      out = run_command %w[
        query
        --consumer-key
        oauth_consumer_key
        --consumer-secret
        oauth_consumer_secret
        --token
        TOKEN
        --secret
        SECRET
        --uri
        http://example.com/oauth/url
      ]

      expect(out).to eq(<<~EXPECTED)
        http://example.com/oauth/url?oauth_consumer_key=oauth_consumer_key&oauth_nonce=GENERATE_KEY&oauth_timestamp=GENERATE_TIMESTAMP&oauth_token=TOKEN&oauth_signature_method=HMAC-SHA1&oauth_version=1.0
        !code! !message!
        !body!
      EXPECTED
    end

    it "performs authorize and prompts/prints response" do
      access_token = instance_double("OAuth::AccessToken", params: {})
      consumer = instance_double("OAuth::Consumer")
      request_token = instance_double("OAuth::RequestToken")

      allow(OAuth::Helper).to receive(:generate_key).and_return("GENERATE_KEY")
      allow(OAuth::Helper).to receive(:generate_timestamp).and_return("GENERATE_TIMESTAMP")

      expect(OAuth::Consumer).to receive(:new) do |key, secret, options|
        expected = {access_token_url: nil, authorize_url: nil, request_token_url: nil, scheme: :header, http_method: :get}
        expect(key).to eq("oauth_consumer_key")
        expect(secret).to eq("oauth_consumer_secret")
        expect(options).to eq(expected)
        consumer
      end

      expect(consumer).to receive(:get_request_token).with({oauth_callback: nil}, {}).and_return(request_token)
      expect(request_token).to receive(:callback_confirmed?).and_return(false)
      expect(request_token).to receive(:authorize_url).and_return("!url1!")
      expect(request_token).to receive(:get_access_token).with({oauth_verifier: nil}).and_return(access_token)

      out = run_command %w[
        authorize
        --consumer-key
        oauth_consumer_key
        --consumer-secret
        oauth_consumer_secret
        --method
        GET
        --uri
        http://example.com/oauth/url
      ]

      expect(out).to eq(<<~EXPECTED)
        Please visit this url to authorize:
        !url1!
        Press return to continue...
        Response:
      EXPECTED
    end

    it "signs a request and prints signature details and value" do
      instance_double("OAuth::AccessToken", params: {})
      instance_double("OAuth::Consumer")
      instance_double("OAuth::RequestToken")

      allow(OAuth::Helper).to receive(:generate_key).and_return("GENERATE_KEY")
      allow(OAuth::Helper).to receive(:generate_timestamp).and_return("GENERATE_TIMESTAMP")

      out = []

      out << run_command(%w[
        sign
        --consumer-key
        oauth_consumer_key
        --consumer-secret
        oauth_consumer_secret
        --method
        GET
        --token
        TOKEN
        --secret
        SECRET
        --uri
        http://example.com/oauth/url
        -v
      ])

      out << run_command(%w[
        sign
        --consumer-key
        oauth_consumer_key
        --consumer-secret
        oauth_consumer_secret
        --method
        GET
        --token
        TOKEN
        --secret
        SECRET
        --uri
        http://example.com/oauth/url
      ])

      expect(out.pop).to eq(<<~EXPECTED)
        MujZyJYT5ix2s388yF8sExvPIgA=
      EXPECTED

      expect(out.pop).to eq(<<~EXPECTED)
        OAuth parameters:
          oauth_consumer_key: oauth_consumer_key
          oauth_nonce: GENERATE_KEY
          oauth_timestamp: GENERATE_TIMESTAMP
          oauth_token: TOKEN
          oauth_signature_method: HMAC-SHA1
          oauth_version: 1.0

        Method: GET
        URI: http://example.com/oauth/url
        Normalized params: oauth_consumer_key=oauth_consumer_key&oauth_nonce=GENERATE_KEY&oauth_signature_method=HMAC-SHA1&oauth_timestamp=GENERATE_TIMESTAMP&oauth_token=TOKEN&oauth_version=1.0
        Signature base string: GET&http%3A%2F%2Fexample.com%2Foauth%2Furl&oauth_consumer_key%3Doauth_consumer_key%26oauth_nonce%3DGENERATE_KEY%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3DGENERATE_TIMESTAMP%26oauth_token%3DTOKEN%26oauth_version%3D1.0
        OAuth Request URI: http://example.com/oauth/url?oauth_consumer_key=oauth_consumer_key&oauth_nonce=GENERATE_KEY&oauth_signature=MujZyJYT5ix2s388yF8sExvPIgA%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=GENERATE_TIMESTAMP&oauth_token=TOKEN&oauth_version=1.0
        Request URI: http://example.com/oauth/url?
        Authorization header: OAuth oauth_consumer_key="oauth_consumer_key", oauth_nonce="GENERATE_KEY", oauth_timestamp="GENERATE_TIMESTAMP", oauth_token="TOKEN", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_signature="MujZyJYT5ix2s388yF8sExvPIgA%3D"
        Signature:         MujZyJYT5ix2s388yF8sExvPIgA=
        Escaped signature: MujZyJYT5ix2s388yF8sExvPIgA%3D
      EXPECTED
    end
  end

  def help_output
    <<~EXPECTED
      Usage: oauth <command> [ARGS]
          -B, --body                       Use the request body for OAuth parameters.
              --consumer-key KEY           Specifies the consumer key to use.
              --consumer-secret SECRET     Specifies the consumer secret to use.
          -H, --header                     Use the 'Authorization' header for OAuth parameters (default).
          -Q, --query-string               Use the query string for OAuth parameters.
          -O, --options FILE               Read options from a file

        options for signing and querying
              --method METHOD              Specifies the method (e.g. GET) to use when signing.
              --nonce NONCE                Specifies the nonce to use.
              --parameters PARAMS          Specifies the parameters to use when signing.
              --signature-method METHOD    Specifies the signature method to use; defaults to HMAC-SHA1.
              --token TOKEN                Specifies the token to use.
              --secret SECRET              Specifies the token secret to use.
              --timestamp TIMESTAMP        Specifies the timestamp to use.
              --realm REALM                Specifies the realm to use.
              --uri URI                    Specifies the URI to use when signing.
              --version [VERSION]          Specifies the OAuth version to use.
              --no-version                 Omit oauth_version.
              --xmpp                       Generate XMPP stanzas.
          -v, --verbose                    Be verbose.

        options for authorization
              --access-token-url URL       Specifies the access token URL.
              --authorize-url URL          Specifies the authorization URL.
              --callback-url URL           Specifies a callback URL.
              --request-token-url URL      Specifies the request token URL.
              --scope SCOPE                Specifies the scope (Google-specific).
    EXPECTED
  end
end
