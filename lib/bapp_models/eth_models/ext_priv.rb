module BAppModels
  module EthModelExtPriv

    def get_raw(id)
      public_key = PrivacyEC.own_public_key_ec
      address = PrivacyEC.pub_to_address(public_key)
      data = ETH["#{resource}:#{id}:address:#{address}"]
      return unless data
      decode_hex data
      initialize_raw data
    end

    private

    def initialize_raw(data)
      instance = new
      @@raw = data
      def instance.raw
        @@raw
      end
      instance
    end

  end
end


# @mkv notes - choose two options - encrypt every parameter in the hash (slower) or everything in 1 go (but then provide a params_public)
