# frozen_string_literal: true

require "net/http"
require "base64"
require "openssl"
require "oauth/consumer"
require "oauth/signature/rsa/sha1"

RSpec.describe OAuth::Signature::RSA::SHA1 do
  def project_spec_dir
    # two levels up from spec/oauth/signature -> spec
    File.expand_path(File.join(__dir__, "../.."))
  end

  def pem_path
    File.expand_path("support/fixtures/keys/rsa.pem", project_spec_dir)
  end

  def cert_path
    File.expand_path("support/fixtures/keys/rsa.cert", project_spec_dir)
  end

  def consumer_key
    "dpf43f3p2l4k3l03"
  end

  def x509_certificate
    OpenSSL::X509::Certificate.new(File.read(cert_path))
  end

  def pkey_rsa
    OpenSSL::PKey::RSA.new(File.read(pem_path))
  end

  def sha1_available?
    key = pkey_rsa
    key.sign(OpenSSL::Digest.new("SHA1"), "x")
    true
  rescue OpenSSL::PKey::PKeyError
    false
  end

  let(:request) do
    Net::HTTP::Get.new("/photos?file=vacaction.jpg&size=original&oauth_version=1.0&oauth_consumer_key=#{consumer_key}&oauth_timestamp=1196666512&oauth_nonce=13917289812797014437&oauth_signature_method=RSA-SHA1")
  end

  let(:consumer) { OAuth::Consumer.new(consumer_key, pkey_rsa) }

  before do
    skip("Skipping RSA-SHA1 tests: SHA1 digest not available in this OpenSSL provider") unless sha1_available?
  end

  it "implements rsa-sha1" do
    expect(OAuth::Signature.available_methods).to include("rsa-sha1")
  end

  it "produces matching signature base string for example request" do
    sbs = OAuth::Signature.signature_base_string(request, {
      consumer: consumer,
      uri: "http://photos.example.net/photos",
    })

    expect(sbs).to eq(
      "GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacaction.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3D13917289812797014437%26oauth_signature_method%3DRSA-SHA1%26oauth_timestamp%3D1196666512%26oauth_version%3D1.0%26size%3Doriginal",
    )
  end

  it "produces matching signature for example request" do
    signature = OAuth::Signature.sign(request, {
      consumer: consumer,
      uri: "http://photos.example.net/photos",
    })

    expect(signature).to eq(
      "jvTp/wX1TYtByB1m+Pbyo0lnCOLIsyGCH7wke8AUs3BpnwZJtAuEJkvQL2/9n4s5wUmUl4aCI4BwpraNx4RtEXMe5qg5T1LVTGliMRpKasKsW//e+RinhejgCuzoH26dyF8iY2ZZ/5D1ilgeijhV/vBka5twt399mXwaYdCwFYE=",
    )
  end

  it "produces matching signature using private_key_file option" do
    consumer2 = OAuth::Consumer.new(consumer_key, nil)

    signature = OAuth::Signature.sign(request, {
      consumer: consumer2,
      private_key_file: pem_path,
      uri: "http://photos.example.net/photos",
    })

    expect(signature).to eq(
      "jvTp/wX1TYtByB1m+Pbyo0lnCOLIsyGCH7wke8AUs3BpnwZJtAuEJkvQL2/9n4s5wUmUl4aCI4BwpraNx4RtEXMe5qg5T1LVTGliMRpKasKsW//e+RinhejgCuzoH26dyF8iY2ZZ/5D1ilgeijhV/vBka5twt399mXwaYdCwFYE=",
    )
  end

  it "verifies signature when consumer has x509 certificate" do
    req2 = Net::HTTP::Get.new("/photos?oauth_signature_method=RSA-SHA1&oauth_version=1.0&oauth_consumer_key=#{consumer_key}&oauth_timestamp=1196666512&oauth_nonce=13917289812797014437&file=vacaction.jpg&size=original&oauth_signature=jvTp%2FwX1TYtByB1m%2BPbyo0lnCOLIsyGCH7wke8AUs3BpnwZJtAuEJkvQL2%2F9n4s5wUmUl4aCI4BwpraNx4RtEXMe5qg5T1LVTGliMRpKasKsW%2F%2Fe%2BRinhejgCuzoH26dyF8iY2ZZ%2F5D1ilgeijhV%2FvBka5twt399mXwaYdCwFYE%3D")
    consumer3 = OAuth::Consumer.new(consumer_key, x509_certificate)

    expect(
      OAuth::Signature.verify(req2, {
        consumer: consumer3,
        uri: "http://photos.example.net/photos",
      }),
    ).to be true
  end

  it "verifies signature with pem in consumer secret" do
    req2 = Net::HTTP::Get.new("/photos?oauth_signature_method=RSA-SHA1&oauth_version=1.0&oauth_consumer_key=#{consumer_key}&oauth_timestamp=1196666512&oauth_nonce=13917289812797014437&file=vacaction.jpg&size=original&oauth_signature=jvTp%2FwX1TYtByB1m%2BPbyo0lnCOLIsyGCH7wke8AUs3BpnwZJtAuEJkvQL2%2F9n4s5wUmUl4aCI4BwpraNx4RtEXMe5qg5T1LVTGliMRpKasKsW%2F%2Fe%2BRinhejgCuzoH26dyF8iY2ZZ%2F5D1ilgeijhV%2FvBka5twt399mXwaYdCwFYE%3D")

    expect(
      OAuth::Signature.verify(req2, {
        consumer: consumer,
        uri: "http://photos.example.net/photos",
      }),
    ).to be true
  end

  it "computes body_hash with request body" do
    post = Net::HTTP::Post.new("/photos")
    post.body = "abc123"

    proxy = OAuth::RequestProxy.proxy(post, {uri: "http://photos.example.net/photos"})
    signer = described_class.new(proxy, {consumer: consumer})

    expected = begin
      Base64.encode64(OpenSSL::Digest.digest("SHA1", "abc123")).chomp.delete("\n")
    rescue StandardError
      Base64.encode64(Digest::SHA1.digest("abc123")).chomp.delete("\n")
    end

    expect(signer.body_hash).to eq(expected)
  end

  it "derives public key from string PEM" do
    pem = File.read(pem_path)
    consumer_pem = OAuth::Consumer.new(consumer_key, pem)

    proxy = OAuth::RequestProxy.proxy(request, {uri: "http://photos.example.net/photos"})
    signer = described_class.new(proxy, {consumer: consumer_pem})

    expect(signer.public_key).to be_a(OpenSSL::PKey::RSA)
  end

  it "derives public key from string certificate" do
    cert = File.read(cert_path)
    consumer_cert = OAuth::Consumer.new(consumer_key, cert)

    proxy = OAuth::RequestProxy.proxy(request, {uri: "http://photos.example.net/photos"})
    signer = described_class.new(proxy, {consumer: consumer_cert})

    expect(signer.public_key).to be_a(OpenSSL::PKey::RSA)
  end

  it "supports direct equality operator with correct signature" do
    proxy = OAuth::RequestProxy.proxy(request, {uri: "http://photos.example.net/photos", consumer: consumer})
    signer = described_class.new(proxy, {consumer: consumer})
    good_sig = "jvTp/wX1TYtByB1m+Pbyo0lnCOLIsyGCH7wke8AUs3BpnwZJtAuEJkvQL2/9n4s5wUmUl4aCI4BwpraNx4RtEXMe5qg5T1LVTGliMRpKasKsW//e+RinhejgCuzoH26dyF8iY2ZZ/5D1ilgeijhV/vBka5twt399mXwaYdCwFYE="
    expect(signer == good_sig).to be true
  end

  it "supports direct equality operator with incorrect signature" do
    proxy = OAuth::RequestProxy.proxy(request, {uri: "http://photos.example.net/photos", consumer: consumer})
    signer = described_class.new(proxy, {consumer: consumer})
    expect(signer == "Invalid==").to be false
  end

  it "honors :private_key option for digest/signature" do
    consumer_nil = OAuth::Consumer.new(consumer_key, nil)
    proxy = OAuth::RequestProxy.proxy(request, {uri: "http://photos.example.net/photos"})

    sig1 = OAuth::Signature.sign(request, {
      consumer: consumer_nil,
      private_key: File.read(pem_path),
      uri: "http://photos.example.net/photos",
    })

    signer = described_class.new(proxy, {consumer: consumer_nil, private_key: File.read(pem_path)})
    sig2 = signer.signature

    expect(sig1).to eq(sig2)
  end

  it "verify returns false for invalid signature" do
    bad_request = Net::HTTP::Get.new("/photos?oauth_signature_method=RSA-SHA1&oauth_version=1.0&oauth_consumer_key=#{consumer_key}&oauth_timestamp=1196666512&oauth_nonce=13917289812797014437&file=vacaction.jpg&size=original&oauth_signature=INVALID%3D")
    consumer_cert = OAuth::Consumer.new(consumer_key, x509_certificate)

    expect(
      OAuth::Signature.verify(bad_request, {consumer: consumer_cert, uri: "http://photos.example.net/photos"}),
    ).to be false
  end
end
