#!/usr/bin/env ruby -r rubygems
# frozen_string_literal: true

# Usage examples:
#  ./scheme_data_importer.rb \
#    --script-id 8xx \
#    --deploy-id x \
#    --realm 7xxxxxxx \
#    --consumer-key 4xxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
#    --consumer-secret 2xxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
#    --token 7xxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
#    --token-secret 5xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#
# This example demonstrates how to sign an OAuth 1.0 HMAC-SHA256 GET request
# including oauth params and query params in the signature base string, and
# send the Authorization header to a NetSuite-hosted endpoint.

require "oauth"
require "net/http"
require "uri"
require "json"
require "securerandom"
require "openssl"
require "base64"
require "optparse"
require "pp"

class SchemeDataImporter
  attr_reader :script_id, :deploy_id, :realm, :consumer, :token

  def initialize(script_id, deploy_id, realm, consumer_key, consumer_secret, token_value, token_secret)
    @script_id = script_id
    @deploy_id = deploy_id
    @realm = realm
    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {
      site: "https://#{realm}.xyz.netsuite.com",
      signature_method: "HMAC-SHA256",
      oauth_version: "1.0",
    })

    # AccessToken must be constructed with the token and token_secret
    @token = OAuth::AccessToken.new(@consumer, token_value, token_secret)
    @token_secret = token_secret || ""
  end

  def import_data
    base_uri = "https://#{realm}.xyz.netsuite.com/app/site/hosting/xyz.nz"
    request_path = "#{base_uri}?script=#{OAuth::Helper.escape(script_id)}&deploy=#{OAuth::Helper.escape(deploy_id)}"

    auth_header, debug = generate_auth_header(base_uri, {"script" => script_id, "deploy" => deploy_id})

    puts "Authorization header: #{auth_header}"
    puts "Base string: #{debug[:base_string]}"
    puts "Signing key: #{debug[:signing_key]}"
    puts "Signature: #{debug[:signature]}"

    uri = URI(request_path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Authorization"] = auth_header
    req["Content-Type"] = "application/json"
    req["Accept"] = "application/json"

    response = http.request(req)

    puts "Response Code: #{response.code}"
    puts "Response Message: #{response.message}"
    puts "Response Body: #{response.body}"

    if response.code.to_i == 200
      puts "Import process complete"
      begin
        JSON.parse(response.body)
      rescue
        response.body
      end
    else
      raise "Failed to fetch data: #{response.code} #{response.message} - #{response.body}"
    end
  end

  private

  def generate_auth_header(base_uri, query_params = {})
    oauth_params = {
      "oauth_consumer_key" => @consumer.key,
      "oauth_token" => @token.token,
      "oauth_signature_method" => "HMAC-SHA256",
      "oauth_timestamp" => Time.now.to_i.to_s,
      "oauth_nonce" => generate_nonce,
      "oauth_version" => "1.0",
    }

    all_params = oauth_params.merge(query_params)

    base_string = generate_base_string("GET", base_uri, all_params)

    signing_key = "#{OAuth::Helper.escape(@consumer.secret)}&#{OAuth::Helper.escape(@token_secret.to_s)}"

    digest = OpenSSL::HMAC.digest("sha256", signing_key, base_string)
    signature = Base64.strict_encode64(digest)

    oauth_params["oauth_signature"] = signature

    header_params = oauth_params.sort.map do |k, v|
      %(#{OAuth::Helper.escape(k)}="#{OAuth::Helper.escape(v)}")
    end
    header = "OAuth " + %(realm="#{OAuth::Helper.escape(realm)}") + ", " + header_params.join(", ")

    debug = {
      base_string: base_string,
      signing_key: signing_key,
      signature: signature,
    }

    [header, debug]
  end

  def generate_nonce
    SecureRandom.hex(16)
  end

  def generate_base_string(http_method, base_uri, params)
    encoded_pairs = params.map do |k, v|
      [OAuth::Helper.escape(k.to_s), OAuth::Helper.escape(v.to_s)]
    end

    encoded_pairs.sort_by! { |k, v| [k, v] }

    normalized = encoded_pairs.map { |k, v| "#{k}=#{v}" }.join("&")

    method = http_method.upcase
    "#{method}&#{OAuth::Helper.escape(base_uri)}&#{OAuth::Helper.escape(normalized)}"
  end
end

# ----------------
# CLI / Example runner
options = {}

op = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on("--script-id ID", "Script ID to call") { |v| options[:script_id] = v }
  opts.on("--deploy-id ID", "Deploy ID to call") { |v| options[:deploy_id] = v }
  opts.on("--realm REALM", "Account realm (subdomain)") { |v| options[:realm] = v }
  opts.on("--consumer-key KEY", "Consumer key") { |v| options[:consumer_key] = v }
  opts.on("--consumer-secret SECRET", "Consumer secret") { |v| options[:consumer_secret] = v }
  opts.on("--token TOKEN", "Access token") { |v| options[:token] = v }
  opts.on("--token-secret SECRET", "Access token secret") { |v| options[:token_secret] = v }
end

op.parse!

required = %i[script_id deploy_id realm consumer_key consumer_secret token token_secret]
missing = required.select { |k| options[k].nil? }
if missing.any?
  puts op.help
  puts "Missing options: #{missing.join(", ")}"
  exit 1
end

importer = SchemeDataImporter.new(
  options[:script_id],
  options[:deploy_id],
  options[:realm],
  options[:consumer_key],
  options[:consumer_secret],
  options[:token],
  options[:token_secret],
)

begin
  result = importer.import_data
  pp(result)
rescue => e
  warn("ERROR: #{e.message}")
  exit(1)
end
