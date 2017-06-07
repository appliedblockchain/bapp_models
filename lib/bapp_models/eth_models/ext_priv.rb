module BAppModels
  module EthModelExtPriv

    def get_raw(id)
      data = ETH["#{resource}:#{id}"]
      return unless data
      data = Oj.load data
      new data
    end

  end
end


# @mkv notes - choose two options - encrypt every parameter in the hash (slower) or everything in 1 go (but then provide a params_public)  
