module RC
  module PrivUtils

    def pubkey_to_ec_pubkey(public_key)
      raise "Public Key must start with '04' (bitcoin public key - hex format)" unless public_key[0..1] == "04"
      public_key = public_key[2..-1]
      RLP::Utils.decode_hex public_key
    end

    # TODO: fix
    def user_pub_keys_get(user_ids:)
      # FIXME: don't use User.all - use User.public_keys
      users = User.all(raw: true)
      users.map!{ |user| user.fetch :data }
      users.select! do |user|
        user_ids.include? user.f(:id)
      end
      hash = {}
      users.each do |user|
        id         = user.f(:id)
        public_key = pubkey_to_ec_pubkey user.f(:public_key)
        hash[id]   = public_key
      end
      hash
    end

  end
end
