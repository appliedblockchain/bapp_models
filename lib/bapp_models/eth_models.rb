require 'virtus'
require 'oj'
require 'inflecto'

require_relative 'eth_models/utils'
require_relative 'eth_models/mixin'
require_relative 'eth_models/ext'

module BAppModels
  class EthModel
    def self.eth_model(shared: false)
      extend  EthModelExt
      include EthModelMixin
      include Virtus.model

      attribute :id, Integer
    end
  end
end
