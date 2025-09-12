#!/usr/bin/env ruby -r rubygems
# frozen_string_literal: true

#
#  ./twitter.rb --consumer-key <key> --consumer-secret <secret> <tweet_id>

require "oauth"
require "optparse"
require "json"
require "pp"

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] <query>"

  opts.on("--consumer-key KEY", "Specifies the consumer key to use.") do |v|
    options[:consumer_key] = v
  end

  opts.on("--consumer-secret SECRET", "Specifies the consumer secret to use.") do |v|
    options[:consumer_secret] = v
  end
end

option_parser.parse!
query = ARGV.pop
query = $stdin.read if query == "-"

if options[:consumer_key].nil? || options[:consumer_secret].nil? || query.nil?
  puts option_parser.help
  exit 1
end

consumer = OAuth::Consumer.new(
  options[:consumer_key],
  options[:consumer_secret],
  site: "https://api.twitter.com",
)

access_token = OAuth::AccessToken.new(consumer)

response = access_token.request(:get, "/1.1/statuses/show/#{OAuth::Helper.escape(query)}.json")
rsp = JSON.parse(response.body)
pp rsp
