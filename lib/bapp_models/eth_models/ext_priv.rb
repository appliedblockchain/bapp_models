module BAppModels
  module EthModelExtPriv

    def get_raw(id)
      data = ETH["#{resource}:#{id}"]
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
