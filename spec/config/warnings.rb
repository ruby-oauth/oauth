# frozen_string_literal: true

# Targeted silencing of a noisy deprecation coming from the oauth gem on Ruby >= 3.4.
#
# Example warning seen during specs:
#   .../gems/oauth-1.1.0/lib/oauth/helper.rb:21: warning: URI::RFC3986_PARSER.escape is obsolete. Use URI::RFC2396_PARSER.escape explicitly.
#
# We only filter this single message to avoid hiding other useful warnings.
# This is test-only; it does not affect consumers of the library.
begin
  original_warning_warn = Warning.method(:warn)

  Warning.define_singleton_method(:warn) do |message|
    if message =~ /lib\/oauth\/helper\.rb:.*URI::RFC3986_PARSER\.escape is obsolete/
      # swallow this specific, known deprecation from the oauth gem
      nil
    else
      original_warning_warn.call(message)
    end
  end
rescue StandardError # rubocop:disable Lint/SuppressedException -- best-effort; don't break older Rubies
  # If Warning.method(:warn) is not available on this Ruby, or redefining fails,
  # silently skip — tests can proceed without the filter.
end
