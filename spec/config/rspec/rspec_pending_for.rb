# rspec-pending_for: enable skipping on incompatible Ruby versions
require "rspec/pending_for"

RSpec.configure do |config|
  config.include Rspec::PendingFor
end
