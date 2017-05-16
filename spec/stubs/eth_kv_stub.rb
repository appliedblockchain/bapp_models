module BAppModels
  class EthKV

    # use Redis to stub Ethereum to make Ethereum look like Redis :boom: :mindblowing: (makes possible to test EthKV in isolation)
    class RPC
      R = Redis.new db: 11

      def self.get(contract:, method:, params:)
        R[params.first] || ""
      end

      def self.set(contract:, method:, params:)
        R[params.first] = params.last
      end
    end

    module EthereumABI
      module ABI
        module DecodingError
        end
      end
    end

  end
end
