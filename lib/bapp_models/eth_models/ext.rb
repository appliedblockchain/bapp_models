
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
      data = Oj.load data
      new data
    end

    def create(attrs)
      id = incr
      attrs.merge! id: id
      obj  = new attrs
      data = Oj.dump obj.attributes
      ETH["#{resource}:#{id}"] = data
      obj
    end

    def update(id, *attrs)
      resource = get id
      resource.update Hash[attrs]
    end

    private

    def incr
      SETH["#{resource}:count"] = count + 1
    end
  end
end
