# frozen_string_literal: true

require_relative "lib/oauth/version"

Gem::Specification.new do |spec|
  # "oauth-tty" was extracted from this gem with release 1.1 of this gem
  # It is now a dependency for backward compatibility.
  # The dependency will be removed with release 2.0, by April 2023.
  spec.add_dependency("oauth-tty", ["~> 1.0", ">= 1.0.1"])
  spec.add_dependency("snaky_hash", "~> 2.0")
  spec.add_dependency("version_gem", "~> 1.1")

  spec.cert_chain = ["certs/pboling.pem"]
  spec.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $PROGRAM_NAME.end_with?("gem")

  spec.name = "oauth"
  spec.version = OAuth::Version::VERSION
  spec.license = "MIT"

  spec.authors = ["Pelle Braendgaard", "Blaine Cook", "Larry Halff", "Jesse Clark", "Jon Crosby",
                  "Seth Fitzsimmons", "Matt Sanford", "Aaron Quint", "Peter Boling"]
  spec.email = ["peter.boling@gmail.com", "oauth-ruby@googlegroups.com"]
  spec.summary = "OAuth 1.0 Core Ruby implementation"
  spec.description = "A Ruby wrapper for the original OAuth 1.0 spec."

  spec.homepage = "https://gitlab.com/oauth-xx/oauth"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/-/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/-/issues"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["wiki_uri"] = "#{spec.homepage}/-/wiki"
  spec.metadata["mailing_list_uri"] = "https://groups.google.com/g/oauth-ruby"
  spec.metadata["funding_uri"] = "https://liberapay.com/pboling"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE.txt",
    "README.md",
    "SECURITY.md",
  ]

  spec.required_ruby_version = ">= 2.7"
  spec.post_install_message = "
You have installed oauth version #{OAuth::Version::VERSION}, congratulations!

Please see:
• #{spec.homepage}/-/blob/main/SECURITY.md
• #{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md#111-2022-09-19

Major updates:
1. master branch renamed to main
• Update your local: git checkout master; git branch -m master main; git branch --unset-upstream; git branch -u origin/main
2. Github has been replaced with Gitlab; I wrote about some of the reasons here:
• https://dev.to/galtzo/im-leaving-github-50ba
• Update your local: git remote set-url origin git@gitlab.com:oauth-xx/oauth.git
3. Google Group is active (again)!
• https://groups.google.com/g/oauth-ruby/c/QA_dtrXWXaE
4. Gitter Chat is active (still)!
• https://gitter.im/oauth-xx/
5. Non-commercial support for the 1.x series will end by April, 2025. Please make a plan to upgrade to the next version prior to that date.
Support will be dropped for Ruby 2.7 and any other Ruby versions which will also have reached EOL by then.
6. Gem releases are now cryptographically signed for security.

If you are a human, please consider a donation as I move toward supporting myself with Open Source work:
• https://liberapay.com/pboling
• https://ko-fi.com/pboling
• https://patreon.com/galtzo

If you are a corporation, please consider supporting this project, and open source work generally, with a TideLift subscription.
• https://tidelift.com/funding/github/rubygems/oauth
• Or hire me. I am looking for a job!

Please report issues, and support the project!

Thanks, |7eter l-|. l3oling
"
  spec.add_development_dependency("em-http-request", "~> 1.1.7")
  spec.add_development_dependency("iconv")
  spec.add_development_dependency("minitest", "~> 5.15.0")
  spec.add_development_dependency("mocha")
  spec.add_development_dependency("rack", ">= 3.0")
  spec.add_development_dependency("rack-test")
  spec.add_development_dependency("rails")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("rest-client")
  spec.add_development_dependency("rubocop-lts", "~> 18.0")
  spec.add_development_dependency("typhoeus", ">= 0.1.13")
  spec.add_development_dependency("webmock", "<= 3.19.0")
end
