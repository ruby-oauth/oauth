# frozen_string_literal: true

# Global Extensions
require_relative "ext/backports"

# External libraries
# N/A

# External RSpec & related config
require "kettle/test/rspec"

# Internal ENV config
require_relative "config/debug"
require_relative "config/vcr"
require_relative "config/warnings"

# RSpec config
require_relative "config/rspec/rack_test"
require_relative "config/rspec/rspec_block_is_expected"
require_relative "config/rspec/rspec_core"
require_relative "config/rspec/rspec_pending_for"
require_relative "config/rspec/version_gem"

# Config for development dependencies of this library
# i.e., not configured by this library
#
# Simplecov & related config (must run BEFORE any other requires)
# NOTE: Gemfiles for older rubies won't have kettle-soup-cover.
#       The rescue LoadError handles that scenario.
begin
  require "kettle-soup-cover"
  require "simplecov" if Kettle::Soup::Cover::DO_COV # `.simplecov` is run here!
rescue LoadError => error
  # check the error message and re-raise when unexpected
  raise error unless error.message.include?("kettle")
end

# this library
require "oauth"
# To ensure oauth-tty remains compatible with this gem,
#   and because it was part of this gem until recently.
# oauth/tty will become an optional dependency in a future major release.
require "oauth/tty"
