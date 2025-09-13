require "kettle/soup/cover/config"

# Minimum coverage thresholds are set by kettle-soup-cover.
# It is controlled by ENV variables, which are set in .envrc and loaded via `direnv allow`
# If the values for minimum coverage need to change, they should be changed both there,
#   and in 2 places in .github/workflows/coverage.yml.
SimpleCov.start do
  track_files "lib/**/*.rb"
  track_files "lib/**/*.rake"
  track_files "exe/*.rb"
end
