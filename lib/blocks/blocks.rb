class NullBlockValue
end

class InvalidBlockValue
  attr_reader :error
  def initialize(error)
    @error = error
  end
end

class Blocks

  # -- query

  def self.all
    new.all
  end

  def self.all_from(first_block_id, up_to:)
    new.all_from first_block_id, up_to: up_to
  end

  # -- object

  def initialize
  end

  def all
    last_block_id =  RPC.block_get
    last_block_id = last_block_id.to_i
    first_block_id = [1, last_block_id-200].max

    all_from first_block_id, up_to: last_block_id
  end

  def all_from(first_block_id, up_to:)
    first_block_id.upto(up_to).map do |block_id|
      get id: block_id
    end.compact
  end

  private

  def get(id:)
    RPC.block_by_num id
  end

end
