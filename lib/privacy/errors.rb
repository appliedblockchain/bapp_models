module RC
module Privacy
  class NullAesKeyError < StandardError
    def message
      "The AES key is null - you can't decrypt an AES encrypted message without presenting the encryption key."
    end
  end

  class UserNotPresentError < StandardError
    def initialize(infos)
      @infos = infos
    end

    def message
      "Your are trying to share this model with an user that doesn't exists - please recheck your 'shared_with:' parameter in the Model.create() call - data: #{@infos}"
    end
  end
end
