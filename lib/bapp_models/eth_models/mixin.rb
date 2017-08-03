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
      obj   = klass.new attrs

      addresses = json_load(SETH["#{self.class.resource}:#{id}:addresses"])
      addresses.each do |address|
        public_key = SETH["public_key:#{address}"]
        enc_data = PrivacyEC.encrypt data, public_key: public_key
        ETH["#{self.class.resource}:#{id}:address:#{address}"] = enc_data
      end

      obj
    end

  end
end
