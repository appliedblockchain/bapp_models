module BAppModels
  module EthModelUtils
    def model_name
      self.name.downcase
    end

    def resource
      Inf.pluralize model_name
    end

    alias :collection_name :resource
  end
end
