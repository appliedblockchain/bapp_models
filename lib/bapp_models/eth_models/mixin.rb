module BAppModels
  module EthModelMixin

    include JSONParsing

    def save
      unless id
        self.class.create self.attributes
      else
        raise "TODO: implement save for update"
      end
    end

    def update(attrs_new)
      klass = self.class
      model = klass.get id
      attrs = model.attributes
      attrs.merge! attrs_new
      data  = json_dump attrs
      data = PrivacyEC.encrypt data
      obj   = klass.new attrs
      ETH["#{self.class.resource}:#{id}"] = data
      obj
    end

  end
end
