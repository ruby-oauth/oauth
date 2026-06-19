<a href="https://github.com/ruby-oauth"><img alt="ruby-oauth Logo by Aboling0, CC BY-SA 4.0" src="https://logos.galtzo.com/assets/images/ruby-oauth/avatar-128px.svg" width="14%" align="right"/></a>

# 🔮 OAuth

[![Version][👽versioni]][👽version] [![GitHub tag (latest SemVer)][⛳️tag-img]][⛳️tag] [![License: MIT][📄license-img]][📄license] [![Downloads Rank][👽dl-ranki]][👽dl-rank] [![CodeCov Test Coverage][🏀codecovi]][🏀codecov] [![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls] [![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov] [![QLTY Maintainability][🏀qlty-mnti]][🏀qlty-mnt] [![CI Heads][🚎3-hd-wfi]][🚎3-hd-wf] [![CI Runtime Dependencies @ HEAD][🚎12-crh-wfi]][🚎12-crh-wf] [![CI Current][🚎11-c-wfi]][🚎11-c-wf] [![CI Truffle Ruby][🚎9-t-wfi]][🚎9-t-wf] [![CI JRuby][🚎10-j-wfi]][🚎10-j-wf] [![Deps Locked][🚎13-🔒️-wfi]][🚎13-🔒️-wf] [![Deps Unlocked][🚎14-🔓️-wfi]][🚎14-🔓️-wf] [![CI Test Coverage][🚎2-cov-wfi]][🚎2-cov-wf] [![CI Style][🚎5-st-wfi]][🚎5-st-wf] [![Apache SkyWalking Eyes License Compatibility Check][🚎15-🪪-wfi]][🚎15-🪪-wf]

`if ci_badges.map(&:color).detect { it != "green"}` ☝️ [let me know][✉️discord-invite], as I may have missed the [discord notification][✉️discord-invite].

---

`if ci_badges.map(&:color).all? { it == "green"}` 👇️ send money so I can do more of this. FLOSS maintenance is now my full-time job.

[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate at ko-fi.com][🖇kofi-img]][🖇kofi]

<details markdown="1">
 <summary>👣 How will this project approach the September 2025 hostile takeover of RubyGems? 🚑️</summary>

I've summarized my thoughts in [this blog post](https://dev.to/galtzo/hostile-takeover-of-rubygems-my-thoughts-5hlo).

</details>

## 🌻 Synopsis <a href="https://discord.gg/3qme4XHNKN"><img alt="Galtzo FLOSS Logo by Aboling0, CC BY-SA 4.0" src="https://logos.galtzo.com/assets/images/galtzo-floss/avatar-128px.svg" width="8%" align="right"/></a> <a href="https://ruby-toolbox.com"><img alt="ruby-lang Logo, Yukihiro Matsumoto, Ruby Visual Identity Team, CC BY-SA 2.5" src="https://logos.galtzo.com/assets/images/ruby-lang/avatar-128px.svg" width="8%" align="right"/></a>

OAuth 1.0a is an industry-standard protocol for authorization.
It is an update to the original OAuth 1.0 protocol, and is used by many popular services.

This is a RubyGem for implementing OAuth 1.0 or 1.0a _clients_ and _servers_ in Ruby applications.
See the sibling `oauth2` gem for OAuth 2.0, 2.1, & OIDC clients in Ruby.

All dependencies of this gem are signed, so it can be installed with a `HighSecurity` profile.

* [OAuth 1.0 Spec][oauth1-spec]
* [oauth-tty sibling gem][sibling2-gem] is the OAuth 1.0 / 1.0a CLI.
* [oauth2 sibling gem][sibling-gem] for OAuth 2.0 implementations in Ruby.

[oauth1-spec]: http://oauth.net/core/1.0/
[sibling-gem]: https://gitlab.com/ruby-oauth/oauth2
[sibling2-gem]: https://gitlab.com/ruby-oauth/oauth-tty

### OAuth 1.0 vs 1.0a: What this library implements

This gem targets the OAuth 1.0a behavior (the errata that became RFC 5849), while maintaining compatibility with providers that still behave like classic 1.0.
Here are the key differences between the two and how this gem handles them:

- oauth_callback
  - 1.0: Optional in practice; some providers accepted flows without it.
  - 1.0a: Consumer SHOULD send oauth_callback when obtaining a Request Token, or explicitly use the out-of-band value "oob".
  - This gem: If you do not pass oauth_callback, we default it to "oob" (OUT_OF_BAND). You can opt-out by passing exclude_callback: true.
- oauth_callback_confirmed
  - 1.0: Not specified.
  - 1.0a: Service Provider MUST return oauth_callback_confirmed=true with the Request Token response. This mitigates session fixation.
  - This gem: Parses token responses but does not include oauth_callback_confirmed in the signature base string (it is a response param, not a signed request param).
- oauth_verifier
  - 1.0: Not present.
  - 1.0a: After the user authorizes, the Provider returns an oauth_verifier to the Consumer, and the Consumer MUST include it when exchanging the Request Token for an Access Token.
  - This gem: Supports oauth_verifier across request helpers and request proxies; pass oauth_verifier to get_access_token in 3‑legged flows.

Practical guidance:
- For 3‑legged flows, always supply oauth_callback when calling consumer.get_request_token, and include oauth_verifier when calling request_token.get_access_token.
- For command‑line or non-HTTP clients, use the special OUT_OF_BAND value ("oob") as the oauth_callback and prompt the user to paste back the displayed verifier.

References: [RFC 5849 (OAuth 1.0)](https://datatracker.ietf.org/doc/html/rfc5849), sections 5–7; [1.0a security errata](https://oauth.net/core/1.0a/).

Ruby OAuth has been maintained by a large number of talented
individuals over the years.
The primary maintainer since 2020 is Peter Boling ([@pboling](https://github.com/pboling)).

## 💡 Info you can shake a stick at

| Tokens to Remember | [![Gem name][⛳️name-img]][⛳️gem-name] [![Gem namespace][⛳️namespace-img]][⛳️gem-namespace] |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Works with JRuby | [![JRuby 9.2 Compat][💎jruby-9.2i]][🚎jruby-9.2-wf] [![JRuby 9.3 Compat][💎jruby-9.3i]][🚎jruby-9.3-wf] <br/> [![JRuby 9.4 Compat][💎jruby-9.4i]][🚎jruby-9.4-wf] [![JRuby current Compat][💎jruby-c-i]][🚎10-j-wf] [![JRuby HEAD Compat][💎jruby-headi]][🚎3-hd-wf]|
| Works with Truffle Ruby | [![Truffle Ruby 22.3 Compat][💎truby-22.3i]][🚎truby-22.3-wf] [![Truffle Ruby 23.0 Compat][💎truby-23.0i]][🚎truby-23.0-wf] [![Truffle Ruby 23.1 Compat][💎truby-23.1i]][🚎truby-23.1-wf] <br/> [![Truffle Ruby 24.2 Compat][💎truby-24.2i]][🚎truby-24.2-wf] [![Truffle Ruby 25.0 Compat][💎truby-25.0i]][🚎truby-25.0-wf] [![Truffle Ruby current Compat][💎truby-c-i]][🚎9-t-wf] [![Truffle Ruby HEAD Compat][💎truby-headi]][🚎3-hd-wf]|
| Works with MRI Ruby 4 | [![Ruby current Compat][💎ruby-c-i]][🚎11-c-wf] [![Ruby HEAD Compat][💎ruby-headi]][🚎3-hd-wf]|
| Works with MRI Ruby 3 | [![Ruby 3.0 Compat][💎ruby-3.0i]][🚎ruby-3.0-wf] [![Ruby 3.1 Compat][💎ruby-3.1i]][🚎ruby-3.1-wf] [![Ruby 3.2 Compat][💎ruby-3.2i]][🚎ruby-3.2-wf] [![Ruby 3.3 Compat][💎ruby-3.3i]][🚎ruby-3.3-wf] [![Ruby 3.4 Compat][💎ruby-3.4i]][🚎ruby-3.4-wf]|
| Works with MRI Ruby 2 | ![Ruby 2.3 Compat][💎ruby-2.3i] <br/> [![Ruby 2.4 Compat][💎ruby-2.4i]][🚎ruby-2.4-wf] [![Ruby 2.5 Compat][💎ruby-2.5i]][🚎ruby-2.5-wf] [![Ruby 2.6 Compat][💎ruby-2.6i]][🚎ruby-2.6-wf] [![Ruby 2.7 Compat][💎ruby-2.7i]][🚎ruby-2.7-wf]|
| Support & Community | [![Join Me on Daily.dev's RubyFriends][✉️ruby-friends-img]][✉️ruby-friends] [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite] [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork] [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor] |
| Source | [![Source on GitLab.com][📜src-gl-img]][📜src-gl] [![Source on CodeBerg.org][📜src-cb-img]][📜src-cb] [![Source on Github.com][📜src-gh-img]][📜src-gh] [![The best SHA: dQw4w9WgXcQ!][🧮kloc-img]][🧮kloc] |
| Documentation | [![Current release on RubyDoc.info][📜docs-cr-rd-img]][🚎yard-current] [![YARD on Galtzo.com][📜docs-head-rd-img]][🚎yard-head] [![Maintainer Blog][🚂maint-blog-img]][🚂maint-blog] [![GitLab Wiki][📜gl-wiki-img]][📜gl-wiki] [![GitHub Wiki][📜gh-wiki-img]][📜gh-wiki] |
| Compliance | [![License: MIT][📄license-img]][📄license] [![Apache license compatibility: Category A][📄license-compat-img]][📄license-compat] [![📄ilo-declaration-img]][📄ilo-declaration] [![Security Policy][🔐security-img]][🔐security] [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct] [![SemVer 2.0.0][📌semver-img]][📌semver] |
| Style | [![Enforced Code Style Linter][💎rlts-img]][💎rlts] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog] [![Gitmoji Commits][📌gitmoji-img]][📌gitmoji] [![Compatibility appraised by: appraisal2][💎appraisal2-img]][💎appraisal2] |
| Maintainer 🎖️ | [![Follow Me on LinkedIn][💖🖇linkedin-img]][💖🖇linkedin] [![Follow Me on Ruby.Social][💖🐘ruby-mast-img]][💖🐘ruby-mast] [![Follow Me on Bluesky][💖🦋bluesky-img]][💖🦋bluesky] [![Contact Maintainer][🚂maint-contact-img]][🚂maint-contact] [![My technical writing][💖💁🏼‍♂️devto-img]][💖💁🏼‍♂️devto] |
| `...` 💖 | [![Find Me on WellFound:][💖✌️wellfound-img]][💖✌️wellfound] [![Find Me on CrunchBase][💖💲crunchbase-img]][💖💲crunchbase] [![My LinkTree][💖🌳linktree-img]][💖🌳linktree] [![More About Me][💖💁🏼‍♂️aboutme-img]][💖💁🏼‍♂️aboutme] [🧊][💖🧊berg] [🐙][💖🐙hub] [🛖][💖🛖hut] [🧪][💖🧪lab] |

### Compatibility

Compatible with MRI Ruby 2.3+, and concordant releases of JRuby, and TruffleRuby.
CI workflows and Appraisals are generated for MRI Ruby 2.4+.
This test floor is configured by `ruby.test_minimum` in `.kettle-jem.yml` and
may be higher than the gem's runtime compatibility floor when legacy Rubies are
not practical for the current toolchain.

<a href="https://github.com/kettle-dev"><img alt="kettle-dev Logo by Aboling0, CC BY-SA 4.0" src="https://logos.galtzo.com/assets/images/kettle-dev/avatar-128px.svg" width="14%" align="right"/></a>

The _amazing_ test matrix is powered by the kettle-dev stack.

<details markdown="1">
<summary>How kettle-dev manages complexity in tests</summary>

| Gem | Source | Role | Daily download rank |
|-----|--------|------|---------------------|
| [appraisal2](https://bestgems.org/gems/appraisal2) | [GitHub](https://github.com/appraisal-rb/appraisal2) | multi-dependency Appraisal matrix generation | [![Daily download rank for appraisal2](https://img.shields.io/gem/rd/appraisal2.svg?style=flat-square)](https://bestgems.org/gems/appraisal2) |
| [appraisal2-rubocop](https://bestgems.org/gems/appraisal2-rubocop) | [GitHub](https://github.com/appraisal-rb/appraisal2-rubocop) | RuboCop Appraisal generator integration | [![Daily download rank for appraisal2-rubocop](https://img.shields.io/gem/rd/appraisal2-rubocop.svg?style=flat-square)](https://bestgems.org/gems/appraisal2-rubocop) |
| [kettle-dev](https://bestgems.org/gems/kettle-dev) | [GitHub](https://github.com/kettle-dev/kettle-dev) | development, release, and CI workflow tooling | [![Daily download rank for kettle-dev](https://img.shields.io/gem/rd/kettle-dev.svg?style=flat-square)](https://bestgems.org/gems/kettle-dev) |
| [kettle-jem](https://bestgems.org/gems/kettle-jem) | [GitHub](https://github.com/kettle-dev/kettle-jem) | Appraisals & CI workflow templates | [![Daily download rank for kettle-jem](https://img.shields.io/gem/rd/kettle-jem.svg?style=flat-square)](https://bestgems.org/gems/kettle-jem) |
| [kettle-soup-cover](https://bestgems.org/gems/kettle-soup-cover) | [GitHub](https://github.com/kettle-dev/kettle-soup-cover) | SimpleCov coverage policy and reporting | [![Daily download rank for kettle-soup-cover](https://img.shields.io/gem/rd/kettle-soup-cover.svg?style=flat-square)](https://bestgems.org/gems/kettle-soup-cover) |
| [kettle-test](https://bestgems.org/gems/kettle-test) | [GitHub](https://github.com/kettle-dev/kettle-test) | standard test runner and coverage harness | [![Daily download rank for kettle-test](https://img.shields.io/gem/rd/kettle-test.svg?style=flat-square)](https://bestgems.org/gems/kettle-test) |
| [rubocop-lts](https://bestgems.org/gems/rubocop-lts) | [GitHub](https://github.com/rubocop-lts/rubocop-lts) | Ruby-version-aware linting | [![Daily download rank for rubocop-lts](https://img.shields.io/gem/rd/rubocop-lts.svg?style=flat-square)](https://bestgems.org/gems/rubocop-lts) |
| [turbo_tests2](https://bestgems.org/gems/turbo_tests2) | [GitHub](https://github.com/galtzo-floss/turbo_tests2) | parallel test execution | [![Daily download rank for turbo_tests2](https://img.shields.io/gem/rd/turbo_tests2.svg?style=flat-square)](https://bestgems.org/gems/turbo_tests2) |

</details>

### Federated DVCS

<details markdown="1">
 <summary>Find this repo on federated forges (Coming soon!)</summary>

| Federated [DVCS][💎d-in-dvcs] Repository | Status | Issues | PRs | Wiki | CI | Discussions |
|-------------------------------------------------|-----------------------------------------------------------------------|---------------------------|--------------------------|---------------------------|--------------------------|------------------------------|
| 🧪 [ruby-oauth/oauth on GitLab][📜src-gl] | The Truth | [💚][🤝gl-issues] | [💚][🤝gl-pulls] | [💚][📜gl-wiki] | 🐭 Tiny Matrix | ➖ |
| 🧊 [ruby-oauth/oauth on CodeBerg][📜src-cb] | An Ethical Mirror ([Donate][🤝cb-donate]) | [💚][🤝cb-issues] | [💚][🤝cb-pulls] | ➖ | ⭕️ No Matrix | ➖ |
| 🐙 [ruby-oauth/oauth on GitHub][📜src-gh] | Another Mirror | [💚][🤝gh-issues] | [💚][🤝gh-pulls] | [💚][📜gh-wiki] | 💯 Full Matrix | [💚][gh-discussions] |
| 🎮️ [Discord Server][✉️discord-invite] | [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite] | [Let's][✉️discord-invite] | [talk][✉️discord-invite] | [about][✉️discord-invite] | [this][✉️discord-invite] | [library!][✉️discord-invite] |

</details>

[gh-discussions]: https://github.com/ruby-oauth/oauth/discussions

### Enterprise Support [![Tidelift](https://tidelift.com/badges/package/rubygems/oauth)](https://tidelift.com/subscription/pkg/rubygems-oauth?utm_source=rubygems-oauth&utm_medium=referral&utm_campaign=readme)

Available as part of the Tidelift Subscription.

<details markdown="1">
 <summary>Need enterprise-level guarantees?</summary>

The maintainers of this and thousands of other packages are working with Tidelift to deliver commercial support and maintenance for the open source packages you use to build your applications. Save time, reduce risk, and improve code health, while paying the maintainers of the exact packages you use.

[![Get help from me on Tidelift][🏙️entsup-tidelift-img]][🏙️entsup-tidelift]

- 💡Subscribe for support guarantees covering _all_ your FLOSS dependencies
- 💡Tidelift is part of [Sonar][🏙️entsup-tidelift-sonar]
- 💡Tidelift pays maintainers to maintain the software you depend on!<br/>📊`@`Pointy Haired Boss: An [enterprise support][🏙️entsup-tidelift] subscription is "[never gonna let you down][🧮kloc]", and *supports* open source maintainers

Alternatively:

- [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]
- [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork]
- [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]

</details>

## ✨ Installation

Install the gem and add to the application's Gemfile by executing:

```console
bundle add oauth
```

If bundler is not being used to manage dependencies, install the gem by executing:

```console
gem install oauth
```

## ⚙️ Configuration

This is a ruby library which is intended to be used in creating Ruby Consumer
and Service Provider applications. It is NOT a Rails plugin, but could easily
be used for the foundation for such a Rails plugin.

The main client entry point is `OAuth::Consumer.new(consumer_key, consumer_secret, options)`.
Common options include:

- `:site` - Provider origin, for example `https://provider.example`.
- `:request_token_path`, `:authorize_path`, `:authenticate_path`, `:access_token_path` - Provider endpoint paths. Defaults are `/oauth/request_token`, `/oauth/authorize`, `/oauth/authenticate`, and `/oauth/access_token`.
- `:request_token_url`, `:authorize_url`, `:access_token_url` - Full endpoint URLs. Use these when endpoints are not all under the same `:site` origin.
- `:scheme` - Where OAuth parameters are sent: `:header` by default, or `:body` / `:query_string`.
- `:http_method` - HTTP method for token endpoint requests, `:post` by default.
- `:signature_method` - Signature method, `HMAC-SHA1` by default.
- `:body_hash_enabled` - Whether request body hashes are signed where applicable. Defaults to `true`.
- `:ca_file`, `:proxy`, `:debug_output` - Net::HTTP transport options.
- `:token_request_max_redirects` - Maximum redirects followed while requesting OAuth tokens. Defaults to `10`.
- `:token_request_cross_origin_redirects` - Whether token requests may follow redirects to a different scheme, host, or effective port. Defaults to `false`; only enable this when the provider's token endpoints intentionally redirect across origins.

This gem was originally extracted from @pelle's [oauth-plugin](https://github.com/pelle/oauth-plugin)
gem. After extraction that gem was made to depend on this gem.

Unfortunately, this gem does have some Rails related bits that are
**optional** to load. You don't need Rails! The Rails bits may be pulled out
into a separate gem with the 1.x minor updates of this gem.

## 🔧 Basic Usage

### Extensions

* [oauth-tty (on Gitlab)](https://gitlab.com/ruby-oauth/oauth-tty) ([rubygems.org](https://rubygems.org/gems/oauth-tty))

### Examples

For browser-based three-legged OAuth 1.0a flows, pass an explicit
`oauth_callback` URL when requesting the request token. If you do not pass
`oauth_callback`, this gem defaults it to `"oob"` (out of band), which is
intended for command-line and non-HTTP clients.

```ruby
callback_url = "http://127.0.0.1:3000/oauth/callback"
```

Create a new `OAuth::Consumer` instance by passing it a configuration hash:

```ruby
oauth_consumer = OAuth::Consumer.new(
  "consumer_key",
  "consumer_secret",
  site: "https://provider.example"
)
```

Start the process by requesting a token:

```ruby
request_token = oauth_consumer.get_request_token(oauth_callback: callback_url)

session[:token] = request_token.token
session[:token_secret] = request_token.secret
redirect_to request_token.authorize_url
```

When the user returns to your callback URL, rebuild the request token from the
values you stored and exchange it for an access token. OAuth 1.0a providers
return `oauth_verifier` in the callback, and it must be included in this
exchange.

```ruby
hash = {oauth_token: session[:token], oauth_token_secret: session[:token_secret]}
request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
@photos = access_token.get("/photos.xml")
```

For OAuth 1.0 providers that do not use `oauth_verifier`, call
`request_token.get_access_token` without the verifier.

Now that you have an access token, you can use Typhoeus to interact with the
OAuth provider if you choose.

```ruby
require "typhoeus"
require "oauth/request_proxy/typhoeus_request"

uri = "https://provider.example/photos.xml"
options = {method: :get, headers: {}}
oauth_params = {consumer: oauth_consumer, token: access_token}

hydra = Typhoeus::Hydra.new
req = Typhoeus::Request.new(uri, options) # :method needs to be specified in options
oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(request_uri: uri))
req.options[:headers] ||= {}
req.options[:headers]["Authorization"] = oauth_helper.header # Signs the request
hydra.queue(req)
hydra.run
@response = req.response
```

### More Information

* RubyDoc Documentation: [![Current release on RubyDoc.info][📜docs-cr-rd-img]][🚎yard-current] [![YARD on Galtzo.com][📜docs-head-rd-img]][🚎yard-head]
* Mailing List/Google Group: [![OAuth Ruby Google Group][⛳gg-discussions-img]][⛳gg-discussions]
* Maintainer Blog: [![Maintainer Blog][🚂maint-blog-img]][🚂maint-blog]
* Live ruby-oauth Chat: [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]

[⛳gg-discussions]: https://groups.google.com/g/oauth-ruby
[⛳gg-discussions-img]: https://img.shields.io/badge/google-group-0093D0.svg?style=for-the-badge&logo=google&logoColor=orange

## 🦷 FLOSS Funding

While ruby-oauth tools are free software and will always be, the project would benefit immensely from some funding.
Raising a monthly budget of... "dollars" would make the project more sustainable.

We welcome both individual and corporate sponsors! We also offer a
wide array of funding channels to account for your preferences.
Currently, [Open Collective][🖇osc] is our preferred funding platform.

**If you're working in a company that's making significant use of ruby-oauth tools we'd
appreciate it if you suggest to your company to become a ruby-oauth sponsor.**

You can support the development of ruby-oauth tools via
[GitHub Sponsors][🖇sponsor],
[Liberapay][⛳liberapay],
[PayPal][🖇paypal],
[Open Collective][🖇osc]
and [Tidelift][🏙️entsup-tidelift].

| 📍 NOTE |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| If doing a sponsorship in the form of donation is problematic for your company <br/> from an accounting standpoint, we'd recommend the use of Tidelift, <br/> where you can get a support-like subscription instead. |

### Open Collective for Individuals

Support us with a monthly donation and help us continue our activities. [[Become a backer](https://opencollective.com/ruby-oauth#backer)]

NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.

<!-- OPENCOLLECTIVE-INDIVIDUALS:START -->
No backers yet. Be the first!
<!-- OPENCOLLECTIVE-INDIVIDUALS:END -->

### Open Collective for Organizations

Become a sponsor and get your logo on our README on GitHub with a link to your site. [[Become a sponsor](https://opencollective.com/ruby-oauth#sponsor)]

NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.

<!-- OPENCOLLECTIVE-ORGANIZATIONS:START -->
No sponsors yet. Be the first!
<!-- OPENCOLLECTIVE-ORGANIZATIONS:END -->

[kettle-readme-backers]: https://github.com/ruby-oauth/oauth/blob/main/bin/kettle-readme-backers

### Another way to support open-source

I’m driven by a passion to foster a thriving open-source community – a space where people can tackle complex problems, no matter how small. Revitalizing libraries that have fallen into disrepair, and building new libraries focused on solving real-world challenges, are my passions. I was recently affected by layoffs, and the tech jobs market is unwelcoming. I’m reaching out here because your support would significantly aid my efforts to provide for my family, and my farm (11 🐔 chickens, 2 🐶 dogs, 3 🐰 rabbits, 8 🐈‍ cats).

If you work at a company that uses my work, please encourage them to support me as a corporate sponsor. My work on gems you use might show up in `bundle fund`.

I’m developing a new library, [floss_funding][🖇floss-funding-gem], designed to empower open-source developers like myself to get paid for the work we do, in a sustainable way. Please give it a look.

**[Floss-Funding.dev][🖇floss-funding.dev]: 👉️ No network calls. 👉️ No tracking. 👉️ No oversight. 👉️ Minimal crypto hashing. 💡 Easily disabled nags**

[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate to my FLOSS efforts at ko-fi.com][🖇kofi-img]][🖇kofi] [![Donate to my FLOSS efforts using Patreon][🖇patreon-img]][🖇patreon]

## 🔐 Security

See [SECURITY.md][🔐security].

## 🤝 Contributing

If you need some ideas of where to help, you could work on adding more code coverage,
or if it is already 💯 (see [below](#code-coverage)) check [issues][🤝gh-issues] or [PRs][🤝gh-pulls],
or use the gem and think about how it could be better.

We [![Keep A Changelog][📗keep-changelog-img]][📗keep-changelog] so if you make changes, remember to update it.

See [CONTRIBUTING.md][🤝contributing] for more detailed instructions.

### 🚀 Release Instructions

See [CONTRIBUTING.md][🤝contributing].

### Code Coverage

<details markdown="1">
<summary>Coverage service badges</summary>

[![Coverage Graph][🏀codecov-g]][🏀codecov]

[![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls]

[![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov]

</details>

### 🪇 Code of Conduct

Everyone interacting with this project's codebases, issue trackers,
chat rooms and mailing lists agrees to follow the [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct].

## 🌈 Contributors

[![Contributors][🖐contributors-img]][🖐contributors]

Made with [contributors-img][🖐contrib-rocks].

Also see GitLab Contributors: [https://gitlab.com/ruby-oauth/oauth/-/graphs/main][🚎contributors-gl]

<details markdown="1">
 <summary>⭐️ Star History</summary>

<a href="https://star-history.com/ruby-oauth/oauth&Date">
 <picture>
 <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ruby-oauth/oauth&type=Date&theme=dark" />
 <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ruby-oauth/oauth&type=Date" />
 <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ruby-oauth/oauth&type=Date" />
 </picture>
</a>

</details>

## 📌 Versioning

This library follows [![Semantic Versioning 2.0.0][📌semver-img]][📌semver] for its public API where practical.
For most applications, prefer the [Pessimistic Version Constraint][📌pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("oauth", "~> 1.0")
```

<details markdown="1">
<summary>📌 Is "Platform Support" part of the public API? More details inside.</summary>

Dropping support for a platform can be a breaking change for affected users.
If a release changes supported platforms, it should be called out clearly in the changelog and versioned with that impact in mind.

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]

</details>

See [CHANGELOG.md][📌changelog] for a list of releases.

## 📄 License

The gem is available as open source under the terms of
the [MIT](MIT.md) [![License: MIT][📄license-img]][📄license-ref].

### © Copyright

See [LICENSE.md][📄license] for the official copyright notice.

<details markdown="1">
<summary>Copyright holders</summary>

- Copyright (c) 2007-2010 Pelle Braendgaard
- Copyright (c) 2008 Chris Mear
- Copyright (c) 2008 Jon Crosby
- Copyright (c) 2008-2010 Seth Fitzsimmons
- Copyright (c) 2008 Tilmann Singer
- Copyright (c) 2008 Tom Insam
- Copyright (c) 2008 tsailipu
- Copyright (c) 2009-2012 Aaron Quint
- Copyright (c) 2009 Anders Conbere
- Copyright (c) 2009 Bill Kocik
- Copyright (c) 2009 Darcy Laycock
- Copyright (c) 2009 Eric Hartmann
- Copyright (c) 2009 Greg Weber
- Copyright (c) 2009 Laszlo Bacsi
- Copyright (c) 2009 Marshall Huss
- Copyright (c) 2009 Matt Sanford
- Copyright (c) 2009 Neill Pearman
- Copyright (c) 2009 Seth Cousins
- Copyright (c) 2009 Yoan Blanc
- Copyright (c) 2010 andrehjr
- Copyright (c) 2010 Brian Finney
- Copyright (c) 2010 ecavazos
- Copyright (c) 2010 Joshua Hull
- Copyright (c) 2010 Marsh Gardiner
- Copyright (c) 2010 Michael Reinsch
- Copyright (c) 2010 Sean Cribbs
- Copyright (c) 2010 Steven Parkes
- Copyright (c) 2010 成田 一生
- Copyright (c) 2011 Shaliko Usubov
- Copyright (c) 2012 Ernie Miller
- Copyright (c) 2012 Jonathon M. Abbott
- Copyright (c) 2012 Richard Huang
- Copyright (c) 2012 rick
- Copyright (c) 2012 Steven Hammond
- Copyright (c) 2013 Craig Walker
- Copyright (c) 2013 Khem Veasna
- Copyright (c) 2014 Brian John
- Copyright (c) 2014 Michal Papis
- Copyright (c) 2014 raeno
- Copyright (c) 2015 jremmen
- Copyright (c) 2015 Kevin Hughes
- Copyright (c) 2016 Eric True
- Copyright (c) 2016-2017 James Pinto
- Copyright (c) 2016 jianben
- Copyright (c) 2016 Nik Wakelin
- Copyright (c) 2017 Ondrej Prazak
- Copyright (c) 2018 Nicholas Souphandavong
- Copyright (c) 2018 Yvonne
- Copyright (c) 2019 Agora@Ubuntu-dev
- Copyright (c) 2019 Shohei Maeda
- Copyright (c) 2020-2021, 2026 Khem
- Copyright (c) 2021 Chuck Remes
- Copyright (c) 2021 iamibi
- Copyright (c) 2021 Jeremy Sioui
- Copyright (c) 2021 Nick Morgan
- Copyright (c) 2021-2022, 2025-2026 Peter H. Boling
- Copyright (c) 2021 Richard Vowles
- Copyright (c) 2022 Shalvah
- Copyright (c) 2024-2025 Annibelle Boling
- Copyright (c) 2025 Aboling0
- Copyright (c) 2026 David Varga
- Copyright (c) 2026 StepSecurity Bot

</details>

## 🤑 A request for help

Maintainers have teeth and need to pay their dentists.
After getting laid off in an RIF in March, and encountering difficulty finding a new one,
I began spending most of my time building open source tools.
I'm hoping to be able to pay for my kids' health insurance this month,
so if you value the work I am doing, I need your support.
Please consider sponsoring me or the project.

To join the community or get help 👇️ Join the Discord.

[![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]

To say "thanks!" ☝️ Join the Discord or 👇️ send money.

[![Sponsor ruby-oauth/oauth on Open Source Collective][🖇osc-all-bottom-img]][🖇osc] 💌 [![Sponsor me on GitHub Sponsors][🖇sponsor-bottom-img]][🖇sponsor] 💌 [![Sponsor me on Liberapay][⛳liberapay-bottom-img]][⛳liberapay] 💌 [![Donate on PayPal][🖇paypal-bottom-img]][🖇paypal]

### Please give the project a star ⭐ ♥.

Many parts of this project are actively managed by a [kettle-jem](https://github.com/structuredmerge/structuredmerge-ruby/tree/main/gems/kettle-jem) smart template utilizing [StructuredMerge.org](https://structuredmerge.org) merge contracts.

Thanks for RTFM. ☺️

[⛳liberapay-img]: https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay&color=a51611&style=flat
[⛳liberapay-bottom-img]: https://img.shields.io/liberapay/goal/pboling.svg?style=for-the-badge&logo=liberapay&color=a51611
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇osc-all-img]: https://img.shields.io/opencollective/all/ruby-oauth
[🖇osc-sponsors-img]: https://img.shields.io/opencollective/sponsors/ruby-oauth
[🖇osc-backers-img]: https://img.shields.io/opencollective/backers/ruby-oauth
[🖇osc-backers]: https://opencollective.com/ruby-oauth#backer
[🖇osc-backers-i]: https://opencollective.com/ruby-oauth/backers/badge.svg?style=flat
[🖇osc-sponsors]: https://opencollective.com/ruby-oauth#sponsor
[🖇osc-sponsors-i]: https://opencollective.com/ruby-oauth/sponsors/badge.svg?style=flat
[🖇osc-all-bottom-img]: https://img.shields.io/opencollective/all/ruby-oauth?style=for-the-badge
[🖇osc-sponsors-bottom-img]: https://img.shields.io/opencollective/sponsors/ruby-oauth?style=for-the-badge
[🖇osc-backers-bottom-img]: https://img.shields.io/opencollective/backers/ruby-oauth?style=for-the-badge
[🖇osc]: https://opencollective.com/ruby-oauth
[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
[🖇sponsor-bottom-img]: https://img.shields.io/badge/Sponsor_Me!-pboling-blue?style=for-the-badge&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🖇polar-img]: https://img.shields.io/badge/polar-donate-a51611.svg?style=flat
[🖇polar]: https://polar.sh/pboling
[🖇kofi-img]: https://img.shields.io/badge/ko--fi-%E2%9C%93-a51611.svg?style=flat
[🖇kofi]: https://ko-fi.com/pboling
[🖇patreon-img]: https://img.shields.io/badge/patreon-donate-a51611.svg?style=flat
[🖇patreon]: https://patreon.com/galtzo
[🖇buyme-small-img]: https://img.shields.io/badge/buy_me_a_coffee-%E2%9C%93-a51611.svg?style=flat
[🖇buyme-img]: https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20latte&emoji=&slug=pboling&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff
[🖇buyme]: https://www.buymeacoffee.com/pboling
[🖇paypal-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=flat&logo=paypal
[🖇paypal-bottom-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=for-the-badge&logo=paypal&color=0A0A0A
[🖇paypal]: https://www.paypal.com/paypalme/peterboling
[🖇floss-funding.dev]: https://floss-funding.dev
[🖇floss-funding-gem]: https://github.com/galtzo-floss/floss_funding
[✉️discord-invite]: https://discord.gg/3qme4XHNKN
[✉️discord-invite-img-ftb]: https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord
[✉️ruby-friends-img]: https://img.shields.io/badge/daily.dev-%F0%9F%92%8E_Ruby_Friends-0A0A0A?style=for-the-badge&logo=dailydotdev&logoColor=white
[✉️ruby-friends]: https://app.daily.dev/squads/rubyfriends

[✇bundle-group-pattern]: https://gist.github.com/pboling/4564780
[⛳️gem-namespace]: https://github.com/ruby-oauth/oauth
[⛳️namespace-img]: https://img.shields.io/badge/namespace-OAuth-3C2D2D.svg?style=square&logo=ruby&logoColor=white
[⛳️gem-name]: https://bestgems.org/gems/oauth
[⛳️name-img]: https://img.shields.io/badge/name-oauth-3C2D2D.svg?style=square&logo=rubygems&logoColor=red
[⛳️tag-img]: https://img.shields.io/github/tag/ruby-oauth/oauth.svg
[⛳️tag]: https://github.com/ruby-oauth/oauth/releases
[🚂maint-blog]: http://www.railsbling.com/tags/oauth
[🚂maint-blog-img]: https://img.shields.io/badge/blog-railsbling-0093D0.svg?style=for-the-badge&logo=rubyonrails&logoColor=orange
[🚂maint-contact]: http://www.railsbling.com/contact
[🚂maint-contact-img]: https://img.shields.io/badge/Contact-Maintainer-0093D0.svg?style=flat&logo=rubyonrails&logoColor=red
[💖🖇linkedin]: http://www.linkedin.com/in/peterboling
[💖🖇linkedin-img]: https://img.shields.io/badge/LinkedIn-Profile-0B66C2?style=flat&logo=newjapanprowrestling
[💖✌️wellfound]: https://wellfound.com/u/peter-boling
[💖✌️wellfound-img]: https://img.shields.io/badge/peter--boling-orange?style=flat&logo=wellfound
[💖💲crunchbase]: https://www.crunchbase.com/person/peter-boling
[💖💲crunchbase-img]: https://img.shields.io/badge/peter--boling-purple?style=flat&logo=crunchbase
[💖🐘ruby-mast]: https://ruby.social/@galtzo
[💖🐘ruby-mast-img]: https://img.shields.io/mastodon/follow/109447111526622197?domain=https://ruby.social&style=flat&logo=mastodon&label=Ruby%20@galtzo
[💖🦋bluesky]: https://bsky.app/profile/galtzo.com
[💖🦋bluesky-img]: https://img.shields.io/badge/@galtzo.com-0285FF?style=flat&logo=bluesky&logoColor=white
[💖🌳linktree]: https://linktr.ee/galtzo
[💖🌳linktree-img]: https://img.shields.io/badge/galtzo-purple?style=flat&logo=linktree
[💖💁🏼‍♂️devto]: https://dev.to/galtzo
[💖💁🏼‍♂️devto-img]: https://img.shields.io/badge/dev.to-0A0A0A?style=flat&logo=devdotto&logoColor=white
[💖💁🏼‍♂️aboutme]: https://about.me/peter.boling
[💖💁🏼‍♂️aboutme-img]: https://img.shields.io/badge/about.me-0A0A0A?style=flat&logo=aboutme&logoColor=white
[💖🧊berg]: https://codeberg.org/pboling
[💖🐙hub]: https://github.org/pboling
[💖🛖hut]: https://sr.ht/~galtzo/
[💖🧪lab]: https://gitlab.com/pboling
[👨🏼‍🏫expsup-upwork]: https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share
[👨🏼‍🏫expsup-upwork-img]: https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white
[👨🏼‍🏫expsup-codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
[👨🏼‍🏫expsup-codementor-img]: https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white
[🏙️entsup-tidelift]: https://tidelift.com/subscription/pkg/rubygems-oauth?utm_source=rubygems-oauth&utm_medium=referral&utm_campaign=readme
[🏙️entsup-tidelift-img]: https://img.shields.io/badge/Tidelift_and_Sonar-Enterprise_Support-FD3456?style=for-the-badge&logo=sonar&logoColor=white
[🏙️entsup-tidelift-sonar]: https://blog.tidelift.com/tidelift-joins-sonar
[💁🏼‍♂️peterboling]: http://www.peterboling.com
[🚂railsbling]: http://www.railsbling.com
[📜src-gl-img]: https://img.shields.io/badge/GitLab-FBA326?style=for-the-badge&logo=Gitlab&logoColor=orange
[📜src-gl]: https://gitlab.com/ruby-oauth/oauth
[📜src-cb-img]: https://img.shields.io/badge/CodeBerg-4893CC?style=for-the-badge&logo=CodeBerg&logoColor=blue
[📜src-cb]: https://codeberg.org/ruby-oauth/oauth
[📜src-gh-img]: https://img.shields.io/badge/GitHub-238636?style=for-the-badge&logo=Github&logoColor=green
[📜src-gh]: https://github.com/ruby-oauth/oauth
[📜docs-cr-rd-img]: https://img.shields.io/badge/RubyDoc-Current_Release-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜docs-head-rd-img]: https://img.shields.io/badge/YARD_on_Galtzo.com-HEAD-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜gl-wiki]: https://gitlab.com/ruby-oauth/oauth/-/wikis/home
[📜gh-wiki]: https://github.com/ruby-oauth/oauth/wiki
[📜gl-wiki-img]: https://img.shields.io/badge/wiki-gitlab-943CD2.svg?style=for-the-badge&logo=gitlab&logoColor=white
[📜gh-wiki-img]: https://img.shields.io/badge/wiki-github-943CD2.svg?style=for-the-badge&logo=github&logoColor=white
[👽dl-rank]: https://bestgems.org/gems/oauth
[👽dl-ranki]: https://img.shields.io/gem/rd/oauth.svg
[👽version]: https://bestgems.org/gems/oauth
[👽versioni]: https://img.shields.io/gem/v/oauth.svg
[🏀qlty-mnt]: https://qlty.sh/gh/ruby-oauth/projects/oauth
[🏀qlty-mnti]: https://qlty.sh/gh/ruby-oauth/projects/oauth/maintainability.svg
[🏀qlty-cov]: https://qlty.sh/gh/ruby-oauth/projects/oauth/metrics/code?sort=coverageRating
[🏀qlty-covi]: https://qlty.sh/gh/ruby-oauth/projects/oauth/coverage.svg
[🏀codecov]: https://codecov.io/gh/ruby-oauth/oauth
[🏀codecovi]: https://codecov.io/gh/ruby-oauth/oauth/graph/badge.svg
[🏀coveralls]: https://coveralls.io/github/ruby-oauth/oauth?branch=main
[🏀coveralls-img]: https://coveralls.io/repos/github/ruby-oauth/oauth/badge.svg?branch=main
[🚎ruby-2.4-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-2.4.yml
[🚎ruby-2.5-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-2.5.yml
[🚎ruby-2.6-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-2.6.yml
[🚎ruby-2.7-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-2.7.yml
[🚎ruby-3.0-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-3.0.yml
[🚎ruby-3.1-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-3.1.yml
[🚎ruby-3.2-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-3.2.yml
[🚎ruby-3.3-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-3.3.yml
[🚎ruby-3.4-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/ruby-3.4.yml
[🚎jruby-9.2-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/jruby-9.2.yml
[🚎jruby-9.3-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/jruby-9.3.yml
[🚎jruby-9.4-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/jruby-9.4.yml
[🚎truby-22.3-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/truffleruby-22.3.yml
[🚎truby-23.0-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/truffleruby-23.0.yml
[🚎truby-23.1-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/truffleruby-23.1.yml
[🚎truby-24.2-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/truffleruby-24.2.yml
[🚎truby-25.0-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/truffleruby-25.0.yml
[🚎2-cov-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/coverage.yml
[🚎2-cov-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/coverage.yml/badge.svg
[🚎3-hd-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/heads.yml
[🚎3-hd-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/heads.yml/badge.svg
[🚎5-st-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/style.yml
[🚎5-st-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/style.yml/badge.svg
[🚎9-t-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/truffle.yml
[🚎9-t-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/truffle.yml/badge.svg
[🚎10-j-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/jruby.yml
[🚎10-j-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/jruby.yml/badge.svg
[🚎11-c-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/current.yml
[🚎11-c-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/current.yml/badge.svg
[🚎12-crh-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/dep-heads.yml
[🚎12-crh-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/dep-heads.yml/badge.svg
[🚎13-🔒️-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/locked_deps.yml
[🚎13-🔒️-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/locked_deps.yml/badge.svg
[🚎14-🔓️-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/unlocked_deps.yml
[🚎14-🔓️-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/unlocked_deps.yml/badge.svg
[🚎15-🪪-wf]: https://github.com/ruby-oauth/oauth/actions/workflows/license-eye.yml
[🚎15-🪪-wfi]: https://github.com/ruby-oauth/oauth/actions/workflows/license-eye.yml/badge.svg
[💎ruby-2.3i]: https://img.shields.io/badge/Ruby-2.3_(%F0%9F%9A%ABCI)-AABBCC?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.4i]: https://img.shields.io/badge/Ruby-2.4-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.5i]: https://img.shields.io/badge/Ruby-2.5-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.6i]: https://img.shields.io/badge/Ruby-2.6-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.7i]: https://img.shields.io/badge/Ruby-2.7-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.0i]: https://img.shields.io/badge/Ruby-3.0-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.1i]: https://img.shields.io/badge/Ruby-3.1-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.2i]: https://img.shields.io/badge/Ruby-3.2-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.3i]: https://img.shields.io/badge/Ruby-3.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.4i]: https://img.shields.io/badge/Ruby-3.4-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-c-i]: https://img.shields.io/badge/Ruby-current-CC342D?style=for-the-badge&logo=ruby&logoColor=green
[💎ruby-headi]: https://img.shields.io/badge/Ruby-HEAD-CC342D?style=for-the-badge&logo=ruby&logoColor=blue
[💎truby-22.3i]: https://img.shields.io/badge/Truffle_Ruby-22.3-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-23.0i]: https://img.shields.io/badge/Truffle_Ruby-23.0-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-23.1i]: https://img.shields.io/badge/Truffle_Ruby-23.1-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-24.2i]: https://img.shields.io/badge/Truffle_Ruby-24.2-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-25.0i]: https://img.shields.io/badge/Truffle_Ruby-25.0-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-c-i]: https://img.shields.io/badge/Truffle_Ruby-current-34BCB1?style=for-the-badge&logo=ruby&logoColor=green
[💎truby-headi]: https://img.shields.io/badge/Truffle_Ruby-HEAD-34BCB1?style=for-the-badge&logo=ruby&logoColor=blue
[💎jruby-9.2i]: https://img.shields.io/badge/JRuby-9.2-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-9.3i]: https://img.shields.io/badge/JRuby-9.3-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-9.4i]: https://img.shields.io/badge/JRuby-9.4-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-c-i]: https://img.shields.io/badge/JRuby-current-FBE742?style=for-the-badge&logo=ruby&logoColor=green
[💎jruby-headi]: https://img.shields.io/badge/JRuby-HEAD-FBE742?style=for-the-badge&logo=ruby&logoColor=blue
[🤝gh-issues]: https://github.com/ruby-oauth/oauth/issues
[🤝gh-pulls]: https://github.com/ruby-oauth/oauth/pulls
[🤝gl-issues]: https://gitlab.com/ruby-oauth/oauth/-/issues
[🤝gl-pulls]: https://gitlab.com/ruby-oauth/oauth/-/merge_requests
[🤝cb-issues]: https://codeberg.org/ruby-oauth/oauth/issues
[🤝cb-pulls]: https://codeberg.org/ruby-oauth/oauth/pulls
[🤝cb-donate]: https://donate.codeberg.org/
[🤝contributing]: https://github.com/ruby-oauth/oauth/blob/main/CONTRIBUTING.md
[🏀codecov-g]: https://codecov.io/gh/ruby-oauth/oauth/graph/badge.svg
[🖐contrib-rocks]: https://contrib.rocks
[🖐contributors]: https://github.com/ruby-oauth/oauth/graphs/contributors
[🖐contributors-img]: https://contrib.rocks/image?repo=ruby-oauth/oauth
[🚎contributors-gl]: https://gitlab.com/ruby-oauth/oauth/-/graphs/main
[🪇conduct]: https://github.com/ruby-oauth/oauth/blob/main/CODE_OF_CONDUCT.md
[🪇conduct-img]: https://img.shields.io/badge/Contributor_Covenant-2.1-259D6C.svg
[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-259D6C.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📌changelog]: https://github.com/ruby-oauth/oauth/blob/main/CHANGELOG.md
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-34495e.svg?style=flat
[📌gitmoji]: https://gitmoji.dev
[📌gitmoji-img]: https://img.shields.io/badge/gitmoji_commits-%20%F0%9F%98%9C%20%F0%9F%98%8D-34495e.svg?style=flat-square
[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[🧮kloc-img]: https://img.shields.io/badge/KLOC-0.946-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue
[🔐security]: https://github.com/ruby-oauth/oauth/blob/main/SECURITY.md
[🔐security-img]: https://img.shields.io/badge/security-policy-259D6C.svg?style=flat
[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
[📄license]: LICENSE.md
[📄license-ref]: MIT.md
[📄license-img]: https://img.shields.io/badge/License-MIT-259D6C.svg
[📄license-compat]: https://www.apache.org/legal/resolved.html#category-a
[📄license-compat-img]: https://img.shields.io/badge/Apache_Compatible:_Category_A-%E2%9C%93-259D6C.svg?style=flat&logo=Apache

[📄ilo-declaration]: https://www.ilo.org/declaration/lang--en/index.htm
[📄ilo-declaration-img]: https://img.shields.io/badge/ILO_Fundamental_Principles-✓-259D6C.svg?style=flat
[🚎yard-current]: http://rubydoc.info/gems/oauth
[🚎yard-head]: https://oauth.galtzo.com
[💎stone_checksums]: https://github.com/galtzo-floss/stone_checksums
[💎SHA_checksums]: https://gitlab.com/ruby-oauth/oauth/-/tree/main/checksums
[💎rlts]: https://github.com/rubocop-lts/rubocop-lts
[💎rlts-img]: https://img.shields.io/badge/code_style_&_linting-rubocop--lts-34495e.svg?plastic&logo=ruby&logoColor=white
[💎appraisal2]: https://github.com/appraisal-rb/appraisal2
[💎appraisal2-img]: https://img.shields.io/badge/appraised_by-appraisal2-34495e.svg?plastic&logo=ruby&logoColor=white
[💎d-in-dvcs]: https://railsbling.com/posts/dvcs/put_the_d_in_dvcs/

<!-- kettle-jem:metadata:start -->
| Field | Value |
|---|---|
| Package | oauth |
| Description | 🔮 A Ruby wrapper for the original OAuth 1.0 / 1.0a spec. |
| Homepage | https://github.com/ruby-oauth/oauth |
| Source | https://github.com/ruby-oauth/oauth |
| License | `MIT` |
| Funding | https://github.com/sponsors/pboling, https://issuehunt.io/u/pboling, https://ko-fi.com/pboling, https://liberapay.com/pboling/donate, https://opencollective.com/ruby-oauth, https://patreon.com/galtzo, https://polar.sh/pboling, https://thanks.dev/u/gh/pboling, https://tidelift.com/funding/github/rubygems/oauth, https://www.buymeacoffee.com/pboling |
<!-- kettle-jem:metadata:end -->
