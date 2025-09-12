# VCR/WebMock: record and replay HTTP to external services (RubyGems, GitHub, etc.)
require "webmock/rspec"
require "vcr"
VCR.configure do |c|
  c.cassette_library_dir = File.join(__dir__, "..", "support", "fixtures", "vcr_cassettes")
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {record: :once}
  # Allow localhost and code coverage server, block others by default when no cassette
  c.ignore_localhost = true
end
WebMock.disable_net_connect!(allow_localhost: true)
