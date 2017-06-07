require "sha3"
require 'ffi'

require 'rlp'


require_relative 'vendor/ecc/ecc_crypto'


# privacy via asymmetric encryption via ECDSA (public key cryptography) - Elliptic Curves - bitcoin secp-k1 (secp-256-k1) via c lib/bindings - TODO secp-zk-snarks

# in your Gemfile
#
# gem "bitcoin-secp256k1", require: 'secp256k1' # lib-secp-k1 bindings (lib-secp-bitcoin - lib-secp)

class PrivacyEC

  # requires keychain

  SHA = SHA3::Digest   # sha3

  module ClassMethods

    def decrypt(encrypted_value)
      key_ecc = private_key_wrap
      key_ecc.ecies_decrypt encrypted_value
    end

    def encrypt(value, public_key: own_public_key)
      ECC_Crypto::ECIES.encrypt value, public_key
    end

    def own_public_key
      Keychain.current.public_key
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
      raise TypeError, 'Non-hexadecimal digit found' unless s =~ /\A[0-9a-fA-F]*\z/
      [str].pack("H*")
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
