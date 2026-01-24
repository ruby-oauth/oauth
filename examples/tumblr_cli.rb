#!/usr/bin/env ruby
# frozen_string_literal: true

# Tumblr CLI
#
# This script is a command-line interface for interacting with the Tumblr API
# using OAuth 1.0a. It performs OAuth bootstrap using an ephemeral local Sinatra
# callback server and immediately transitions into an interactive CLI menu
# without requiring the script to be re-run.
#
# Tumblr App Setup (Required):
# 1. Create a Tumblr application at https://www.tumblr.com/oauth/apps
# 2. Enable OAuth 1.0a for the application
# 3. Set the "Default callback URL" to:
#       http://localhost:4567/callback
#    (Must match exactly: scheme, host, port, and path)
# 4. OAuth2 redirect URLs are not used by this script and may be left empty
#
# Authentication model:
# - Consumer key and secret are provided as CLI arguments.
# - On startup, an ephemeral local Sinatra server is launched on localhost
#   to handle the OAuth 1.0a callback.
# - The server exists only long enough to exchange the OAuth verifier for an
#   access token.
# - Access tokens are stored in memory only (not written to disk).
# - Once OAuth completes, the server shuts down and the CLI menu starts.
#
# Required gems:
#   gem install oauth sinatra puma launchy
#
# Usage:
#   ruby tumblr_cli.rb --consumer-key <KEY> --consumer-secret <SECRET>
#
# Notes:
# - OAuth authorization is required once per execution.
# - This script intentionally uses OAuth 1.0a to demonstrate legacy OAuth
#   handling and Tumblr-specific constraints.

require "optparse"

# CLI Arguments
options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tumblr_cli.rb --consumer-key KEY --consumer-secret SECRET"

  opts.on("--consumer-key KEY", "Tumblr consumer key") do |v|
    options[:consumer_key] = v
  end

  opts.on("--consumer-secret SECRET", "Tumblr consumer secret") do |v|
    options[:consumer_secret] = v
  end
end.parse!

ARGV.clear

unless options[:consumer_key] && options[:consumer_secret]
  puts "Missing required arguments."
  exit 1
end

# Immutable configuration
CONSUMER_KEY = options[:consumer_key].freeze
CONSUMER_SECRET = options[:consumer_secret].freeze

require "sinatra"
require "oauth"
require "launchy"
require "json"
require "uri"

API_BASE = "https://api.tumblr.com/v2"
CALLBACK_URL = "http://localhost:4567/callback"

set :bind, "localhost"
set :port, 4567
set :server, :puma
set :logging, false

# Mutable runtime state (Sinatra-managed)
set :access_token, nil

# OAuth Consumer
def consumer
  OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    site: "https://www.tumblr.com",
    request_token_path: "/oauth/request_token",
    authorize_path: "/oauth/authorize",
    access_token_path: "/oauth/access_token",
    http_method: :post,
  )
end

# OAuth Bootstrap (Ephemeral Sinatra)
REQUEST_TOKENS = {}

get "/" do
  request_token = consumer.get_request_token(
    oauth_callback: CALLBACK_URL,
    http_method: :post,
  )

  REQUEST_TOKENS[request_token.token] = request_token.secret
  redirect request_token.authorize_url
end

get "/callback" do
  token = params[:oauth_token]
  verifier = params[:oauth_verifier]

  request_token = OAuth::RequestToken.new(
    consumer,
    token,
    REQUEST_TOKENS[token],
  )

  settings.access_token = request_token.get_access_token(
    oauth_verifier: verifier,
    http_method: :post,
  )

  puts "\nOAuth complete. Access token acquired.\n"

  Thread.new {
    sleep 1
    Sinatra::Application.quit!
  }
  "Authorization complete. You can close this window."
end

# HTTP Helper
def api_get(path, params = {})
  url = "#{API_BASE}#{path}"
  url += "?#{URI.encode_www_form(params)}" unless params.empty?
  JSON.parse(settings.access_token.get(url).body)
end

# Rendering Helpers
def print_post(post)
  puts "-" * 60
  puts "Type : #{post["type"]}"
  puts "Date : #{post["date"]}"
  puts "URL  : #{post["post_url"]}"

  case post["type"]
  when "text"
    puts "\n#{post["title"]}" if post["title"]
    puts post["body"]
  when "photo"
    puts "\nCaption:"
    puts post["caption"] if post["caption"]
    post["photos"]&.each do |p|
      puts "Photo: #{p["original_size"]["url"]}"
    end
  else
    puts "\nSummary:"
    puts post["summary"]
  end
end

# Lists blogs owned by the authenticated user that have published posts.
#
# This method queries the Tumblr API for the current user's account details
# (`/v2/user/info`) and extracts the set of blogs associated with the user.
# It then filters that list to include only blogs that:
#
# - Are owned by the authenticated user (`admin == true`)
# - Have at least one published post (`posts > 0`)
#
# For each qualifying blog, a short summary is printed to STDOUT including:
# - Blog name
# - Blog URL
# - Total number of posts
#
# API endpoint used:
#   GET /v2/user/info
#
#   This method does not return a value.
def list_my_blogs
  blogs = api_get("/user/info").dig("response", "user", "blogs") || []

  blogs.select { |b| b["admin"] && b["posts"].to_i > 0 }.each do |b|
    puts "-" * 50
    puts "Name : #{b["name"]}"
    puts "URL  : #{b["url"]}"
    puts "Posts: #{b["posts"]}"
  end
end

# Lists blogs owned by the authenticated user and displays the latest full posts
# for each blog.
#
# This method retrieves the current user's blogs via the Tumblr API
# (`/v2/user/info`), filters the list to blogs owned by the authenticated user
# that contain published posts, and then fetches the most recent posts for
# each qualifying blog.
#
# For each blog:
# - A header containing the blog name and total post count is printed
# - The latest five posts are retrieved via the blog posts endpoint
# - Each post is rendered in full using type-aware formatting suitable for
#   command-line output
#
# Post content is displayed directly to STDOUT and may include text bodies,
# captions, media URLs, and summaries depending on post type.
#
# API endpoints used:
#   GET /v2/user/info
#   GET /v2/blog/{blog-identifier}/posts
#
#   This method does not return a value.
def list_my_blogs_with_latest_posts
  blogs = api_get("/user/info").dig("response", "user", "blogs") || []

  blogs.select { |b| b["admin"] && b["posts"].to_i > 0 }.each do |b|
    puts "\n" + "=" * 70
    puts "Blog: #{b["name"]} (#{b["posts"]} posts)"
    puts "=" * 70

    posts = api_get(
      "/blog/#{b["name"]}.tumblr.com/posts",
      limit: 5,
    ).dig("response", "posts") || []

    posts.each { |p| print_post(p) }
  end
end

# Menu
def menu
  loop do
    puts "\nTumblr CLI"
    puts "1) List my blogs (with posts)"
    puts "2) Show latest 5 full posts per blog"
    puts "3) Exit"
    print("> ")

    case STDIN.gets&.strip
    when "1" then list_my_blogs
    when "2" then list_my_blogs_with_latest_posts
    when "3" then exit(0)
    else puts "Invalid option."
    end
  end
end

# Entry Point
puts "Starting Tumblr OAuth flow..."
Launchy.open("http://localhost:4567")

Sinatra::Application.run!

menu
