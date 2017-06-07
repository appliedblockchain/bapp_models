
module BAppModels
  module EthModelMixin

    def update(attrs_new)
      klass = self.class
      model = klass.get id
      attrs = model.attributes
      attrs_priv = []
      # attrs.each |name, value|
      #   attrs_priv[name] = PrivacyAsym.encrypt value
      # end
      attrs.merge! attrs_priv
      obj   = klass.new attrs
      data  = Oj.dump obj.attributes
      ETH["#{self.class.resource}:#{id}"] = data
      obj
    end

  end
end
