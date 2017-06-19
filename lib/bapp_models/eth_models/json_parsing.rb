module BAppModels
  module JSONParsing

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

  end
end
