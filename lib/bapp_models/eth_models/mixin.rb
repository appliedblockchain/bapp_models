
module BAppModels
  module EthModelMixin

    def update(attrs_new)
      klass = self.class
      model = klass.get id
      attrs = model.attributes
      attrs.merge! attrs_new
      obj   = klass.new attrs
      data  = Oj.dump obj.attributes
      ETH["#{self.class.resource}:#{id}"] = data
      obj
    end

  end
end
