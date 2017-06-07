require "openssl"
require 'securerandom'
require "base64" # for handling iv only

require_relative 'priv_utils'
require_relative "#{PATH}/privacy/shared_secrets_lib"


module RC

class NullAesKeyError < StandardError
  def message
    "The AES key is null - you can't decrypt an AES encrypted message without presenting the encryption key."
  end
end

class UserNotPresentError < StandardError
  def initialize(infos)
    @infos = infos
  end

  def message
    "Your are trying to share this model with an user that doesn't exists - please recheck your 'shared_with:' parameter in the Model.create() call - data: #{@infos}"
  end
end

module Privacy

  # SHA = Digest::SHA3 # digest/sha3
  SHA = SHA3::Digest   # sha3

  # SHA = Digest::SHA2
  #
  # usage:
  #  SHA.hexdigest "foo"

  include SharedSecretsLib
  include PrivUtils

  private

  # ---

  # use keychain

  def private_key_wrap
    private_key = CHAIN.keychain.private_key
    ECC_Crypto::ECCx.new RLP::Utils.decode_hex private_key
  end

  def decrypt_value(encrypted_value)
    key_ecc = private_key_wrap
    key_ecc.ecies_decrypt encrypted_value
  end

  def encrypt_value(value, public_key:)
    ECC_Crypto::ECIES.encrypt value, public_key
  end

  AES = OpenSSL::Cipher::AES

  # AES 256 by default - other possibilities (speed vs attack time)
  #
  # AES = OpenSSL::Cipher::AES.new 128, :CBC
  # AES = OpenSSL::Cipher::AES.new 256, :CBC
  # AES = OpenSSL::Cipher::AES.new 512, :CBC

  def aes_encrypt(data, secret_key:)
    # secret_key = AES.random_key # can be used instead of the shared secret
    #
    # optional - introduce NullObject before encryption fails (otherwise we can encrypt empty string into empty string)
    # return NullObject.new if !data || data.empty?

    puts "AES Encrypt - data: #{data.inspect} - secret_key: #{secret_key.inspect}" if MODEL_LOG

    # TODO: handle exceptions
    aes = AES.new 256, :CBC
    aes.encrypt
    aes.key = secret_key # this is shared secred
    iv = aes.random_iv # this also resets the init. vector for next iteration
    data_enc = aes.update(data) + aes.final

    Oj.dump({
      data: data_enc,
      iv:   iv,
    })#.to_json
  end

  # TODO: make a version of these method which is strict and raises exceptions
  #
  def aes_decrypt(data_encrypted, key:)
    # data_enc = JSON.parse data_enc
    data_enc = Oj.load data_encrypted
    data_enc, iv = data_enc.fetch(:data), data_enc.fetch(:iv)

    unless iv
      puts "Error, blank IV for aes_decrypt - data_enc: #{data_encrypted}"
      return nil
    end

    # TODO: handle exceptions
    aes = AES.new 256, :CBC
    aes.decrypt

    begin
      aes.key = key
    rescue TypeError => e
      if key.is_a? NullObject
        raise NullAesKeyError #,  The AES key was null when trying to decrypt a message - message: #{data_encrypted.inspect}"
      else
        puts "Privacy Error - aes_decrypt AES key assignment raised a TypeError - ignoring - outputting nil value - key: #{key.inspect}" if MODEL_LOG
        return nil
      end
    rescue OpenSSL::Cipher::CipherError => e
      puts "Privacy Error - aes_decrypt AES key assignment raised a CipherError - ignoring - outputting nil value - key: #{key.inspect}" if MODEL_LOG
      # raise OpenSSL::Cipher::CipherError, "Got Error - class: #{OpenSSL::Cipher::CipherError} - message: #{e.message} - key: #{key.inspect}, data_enc: #{data_enc.inspect} \n\nstack_trace: \n#{e.backtrace.join("\n")}"
      return nil
    end

    aes.iv  = iv

    value = nil
    begin # rescue 'bad decrypt' error
      value = aes.update(data_enc) + aes.final
    rescue OpenSSL::Cipher::CipherError => e
      puts "Privacy Error - aes_decrypt AES update - bad decrypt - ignoring - outputting nil value - data_enc: #{data_enc.inspect} - key: #{key.inspect}"
      puts e.inspect
      # puts "-"*80
      if ENV["DEBUG"]
        puts e.backtrace
      end
    end
    value
  end

  # ---

  def encrypt_data(data, secret:)
    aes_encrypt data, secret_key: secret
  end

  private

  # rescue TODO add errors DecryptionWrongPrivateKeyError DecriptionError

  def decrypt_secret_enc(secret_enc)
    decrypt_value secret_enc

    # TODO: add errors
  end

  def decrypt_data(data_enc, secret:)
    aes_decrypt data_enc, key: secret

    # TODO: exceptions
  end

  public

  def decrypt(data_enc:, secret_enc:)
    # puts "DECRYPTING DATA - secret_enc: #{secret_enc.inspect}"

    shared_secret = decrypt_secret_enc secret_enc

    unless shared_secret.empty?
      data = decrypt_data data_enc, secret: shared_secret
    else
      puts "Failed to decrypt shared secret, returning nil" if MODEL_LOG
    end

    data
  end

  # ------------
  # TODO: refactor

  # this method encrypts and saves the encrypted secret for every user
  def shared_secret_save_all(secret_raw, coll_name:, model_id:, user_ids:)
    public_keys = user_pub_keys_get user_ids: user_ids

    user_ids.each do |user_id|
      # user_pub
      begin
        public_key = public_keys.fetch user_id
      rescue KeyError => e
        raise UserNotPresentError.new "- user_id: #{user_id.inspect} - coll_name: #{coll_name.inspect}"
      end

      secret_enc = encrypt_value secret_raw, public_key: public_key

      shared_secret_save secret_enc, coll_name: coll_name, model_id: model_id, user_id: user_id
    end

    true
  end

  def shared_secret_decrypt(secret_raw)
    decrypt_value secret_raw
  end

end # Privacy

end
