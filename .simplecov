# kettle-jem:freeze
# To retain chunks of comments & code during oauth templating:
# Wrap custom sections with freeze markers (e.g., as above and below this comment chunk).
# oauth will then preserve content between those markers across template runs.
# kettle-jem:unfreeze

# Minimum coverage thresholds are set by kettle-soup-cover.
# They are controlled by ENV variables loaded by `mise` from `mise.toml`
# (with optional machine-local overrides in `.env.local`).
# If the values for minimum coverage need to change, they should be changed both there,
#   and in 2 places in .github/workflows/coverage.yml.
SimpleCov.configure do
  if SimpleCov::Configuration.method_defined?(:cover)
    cover "lib/**/*.rb", "lib/**/*.rake", "exe/*.rb"
  else
    track_files "{lib/**/*.rb,lib/**/*.rake,exe/*.rb}"
  end
  cover "lib/**/*.rb", "lib/**/*.rake", "exe/*.rb"

  # These adapters are exercised only by appraisals that install their
  # optional framework/client dependencies. The default bundle cannot load
  # them, so counting them would make the core coverage threshold misleading.
  %w[
    lib/oauth/client/action_controller_request.rb
    lib/oauth/client/em_http.rb
    lib/oauth/oauth_test_helper.rb
    lib/oauth/optional.rb
    lib/oauth/request_proxy/action_controller_request.rb
    lib/oauth/request_proxy/action_dispatch_request.rb
    lib/oauth/request_proxy/curb_request.rb
    lib/oauth/request_proxy/em_http_request.rb
  ].each { |path| skip path }
end
# It is controlled by ENV variables, which are set in .envrc and loaded via `direnv allow`
