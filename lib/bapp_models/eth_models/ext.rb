module BAppModels
  module EthModelExt
    include EthModelUtils
    include JSONParsing

    def all
      1.upto(count).map do |entry_id|
        get entry_id
      end
    end

    def count
      ( SETH["#{resource}:count"] || 0 ).to_i
    end

    def get(id)
      data = ETH["#{resource}:#{id}"]
      return unless data
      data = PrivacyEC.decrypt data
      data = json_load data
      new data
    end

    def create(attrs)
      id = incr
      attrs.merge! id: id
      obj  = new attrs
      data = json_dump obj.attributes
      data = PrivacyEC.encrypt data
      ETH["#{resource}:#{id}"] = data
      obj
    end

    def update(id, attrs)
      resource = get id
      resource.update attrs
    end

    def find(search_options)
      models = self.class.all
      models.find do |model|
        search_options.keys.each do |so_key|
          return false unless contract[so_key] == search_options[so_key]
        end
        true
      end
    end

    private

    def incr
      SETH["#{resource}:count"] = count + 1
    end


    # utils - todo: dry with privacy_ec utils?

    def decode_hex(str)
      raise TypeError, "Value must be an instance of string" unless str.instance_of?(String)
      raise TypeError, 'Non-hexadecimal digit found' unless str =~ /\A[0-9a-fA-F]*\z/
      [str].pack("H*")
    end

    protected
    def has_one(model_name)
      # define getter
      define_method model_name do
        Object.const_get(self.class.sym_to_model_name(model_name)).get self["#{model_name}_id"]
      end
    end

    def has_many(model_name)
      # define getter
      define_method model_name do
        potential_relatives = Object.const_get(self.class.sym_to_model_name(model_name)).all
        relatives = []
        search_attribute = "#{self.class.model_name_underscore(self.class.to_s)}_id"
        potential_relatives.each do |pr|
          if pr[search_attribute] == self.id
            relatives << pr
          end
        end
      end
    end

    public
    def model_name_underscore(model_name)
      model_name.scan(/[A-Z][^A-Z]*/).map{|name_el| name_el.downcase }.join("_")
    end

    def sym_to_model_name(sym)
      sym.to_s.split("_").map{|name_el| name_el.capitalize}.join("")
    end

  end
end
