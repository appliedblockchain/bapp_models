require 'sha3'
require 'ffi'
require 'rlp'
require 'secp256k1'

require_relative 'utils'
require_relative 'vendor/ecc/ecc_crypto'


# privacy via asymmetric encryption via ECDSA (public key cryptography) - Elliptic Curves - bitcoin secp-k1 (secp-256-k1) via c lib/bindings - TODO secp-zk-snarks

# in your Gemfile
#
# gem "bitcoin-secp256k1", require: 'secp256k1' # lib-secp-k1 bindings (lib-secp-bitcoin - lib-secp)

class PrivacyEC

  extend Privacy::Utils

  # requires keychain

  SHA = SHA3::Digest   # sha3

  LOG = false

  module ClassMethods

    def decrypt(encrypted_value)
      log "DECRYPT: #{encrypted_value.inspect}"
      encrypted_value = decode_hex encrypted_value
      log "DECRYPT (decoded): #{encrypted_value.inspect}"
      key_ecc = private_key_wrap
      value = key_ecc.ecies_decrypt encrypted_value
      log "DECRYPT (decrypted value): #{value.inspect}"
      value = decode_hex value
      log "DECRYPT (decrypted value decoded): #{value.inspect}"
      value
    end

    def encrypt(value, public_key: own_public_key_ec)
      log "ENCRYPT: #{value.inspect}"
      value = encode_hex value
      log "ENCRYPT (encoded): #{value.inspect}"
      bytes = ECC_Crypto::ECIES.encrypt value, public_key
      log "ENCRYPT (bytes): #{bytes.inspect}"
      encode_hex bytes
    end

    def own_public_key
      Keychain.current.public_key
    end

    def own_public_key_ec
      pubkey_to_ec_pubkey own_public_key
    end

    # utils

    def sha(value)
      SHA.hexdigest value
    end

    protected

    def private_key_wrap
      private_key = Keychain.current.private_key
      ECC_Crypto::ECCx.new decode_hex private_key
    end

    # utils

    def decode_hex(str)
      raise TypeError, "Value must be an instance of string" unless str.instance_of?(String)
      raise TypeError, 'Non-hexadecimal digit found' unless str =~ /\A[0-9a-fA-F]*\z/
      [str].pack("H*")
    end

    def encode_hex(bytes)
      raise TypeError, "Value must be an instance of String" unless bytes.instance_of?(String)
      bytes.unpack("H*").first
    end

    def log(msg)
      return unless LOG
      puts msg
      puts
    end

  end

  extend ClassMethods

end


# notes: you can use sha2 instead of sha3
#
# SHA = Digest::SHA2
#
# usage:
#  SHA.hexdigest "foo"
