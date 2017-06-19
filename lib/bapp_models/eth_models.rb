require 'virtus'
require 'oj'
require 'inflecto'

require_relative 'eth_models/utils'
require_relative 'eth_models/json_parsing'
require_relative 'eth_models/mixin'
require_relative 'eth_models/ext'

# keychain
require_relative '../keychain/keychain'

# +privacy
require_relative 'eth_models/ext_priv'
# ---
require_relative '../privacy/privacy_ec'

module BAppModels
  class EthModel
    def self.eth_model(shared: false)
      extend  EthModelExt
      include EthModelMixin

      # +privacy
      extend EthModelExtPriv

      include Virtus.model

      attribute :id, Integer
    end
  end
end
