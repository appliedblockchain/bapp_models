# Save encrypted shared secret - called during encrypt
# Load shared secret - called on both decrypt and encrypt - needs to be decrypted
#

module RC
module SharedSecretsLib

  # SH_SEC_LOG = true
  SH_SEC_LOG = false

  def shared_secret_generate
    SecureRandom.hex[0..31]
    # TODO: recheck if we can use random_bytes(32) for performance
  end

  def shared_secret_save(secret, coll_name:, model_id:, user_id:)
    secret = Base64.encode64 secret # TODO: remove, not needed with eth (same as below)
    key = "shared_secrets:#{coll_name}:#{model_id}:#{user_id}"
    unless SR[key]
      puts "Shared secret save: #{key.inspect}" if SH_SEC_LOG
      SR[key] = secret
    end
  end

  def shared_secret_load(coll_name:, model_id:, user_id:)
    key = "shared_secrets:#{coll_name}:#{model_id}:#{user_id}"
    puts "Shared secret load: #{key.inspect}" if SH_SEC_LOG
    secret = SR[key]
    Base64.decode64 secret if secret
  end

end
end
