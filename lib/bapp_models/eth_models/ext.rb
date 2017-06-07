module BAppModels
  module EthModelExt
    include EthModelUtils

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

    private

    def incr
      SETH["#{resource}:count"] = count + 1
    end

    # ---

    JSONParseError = Class.new RuntimeError

    def json_load(string)
      Oj.load string
    rescue Oj::ParseError => err
      puts "Error parsing JSON #{err}"
      raise JSONParseError, "Couldn't parse JSON - json: #{string.inspect}"
    end

    def json_dump(data)
      Oj.dump data
      # TODO rescue dump error (circular reference... etc)
    end

    # utils - todo: dry with privacy_ec utils?

    def decode_hex(str)
      raise TypeError, "Value must be an instance of string" unless str.instance_of?(String)
      raise TypeError, 'Non-hexadecimal digit found' unless str =~ /\A[0-9a-fA-F]*\z/
      [str].pack("H*")
    end

  end
end
