# frozen_string_literal: true

module OAuth
  # Out-Of-Band callback token value.
  # OAuth 1.0 and 1.0a both support out-of-band flows, where callbacks cannot be used.
  # See RFC 5849 (OAuth 1.0), Section 6.1.1: Obtaining an Unauthorized Request Token
  # and the 1.0a errata. Providers treating "oob" as the callback URL indicate that
  # the verifier (for 1.0a) will be communicated out of band to the Consumer.
  OUT_OF_BAND = "oob"

  # OAuth parameter keys this library recognizes when normalizing/signing requests.
  # Notes on 1.0 vs 1.0a:
  # - oauth_verifier: Introduced by OAuth 1.0a. Returned to the Consumer after user
  #   authorization and required when exchanging a Request Token for an Access Token
  #   (Section 6.3.1 in RFC 5849 / 1.0a change).
  # - oauth_callback: Present in 1.0; 1.0a clarified that the Consumer MUST send it when
  #   obtaining a Request Token (or use "oob") and that the Service Provider MUST return
  #   oauth_callback_confirmed=true with the Request Token response to prevent session
  #   fixation attacks. Note that oauth_callback_confirmed is a response parameter, not
  #   a request signing parameter, and thus is not listed here.
  # Other keys are common to both 1.0 and 1.0a.
  PARAMETERS = %w[
    oauth_callback
    oauth_consumer_key
    oauth_token
    oauth_signature_method
    oauth_timestamp
    oauth_nonce
    oauth_verifier
    oauth_version
    oauth_signature
    oauth_body_hash
  ].freeze

  # reserved character regexp, per section 5.1
  RESERVED_CHARACTERS = /[^a-zA-Z0-9\-._~]/.freeze
end
