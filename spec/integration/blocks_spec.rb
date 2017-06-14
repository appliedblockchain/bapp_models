require_relative "spec_helper_integration"

require_relative '../../lib/blocks/blocks'

STATE = {}

RSpec.describe Blocks do

  # prereqs

  specify "setup - connects to ETH" do
    block = RPC.block_get
    block.should_not be nil
    block.should be_a Integer
    block.should be > 0
  end

  specify "setup - updates last block with a predictable transaction" do
    RPC.set contract: :key_value, method: :set, params: ["foo", "bar"]
  end

  specify "gets TX" do
    block = Blocks.all.last
    txs = block.fetch :transactions
    tx = txs.first
    STATE[:tx] = tx
  end

  specify "decode transaction" do
    tx = STATE[:tx]

    tx_data = Blocks::Transaction.read tx: tx, format: :original

    tx_data.should have_key :method_id
    tx_data[:method_id] = "0xa18c751e"

    tx_data.should have_key :name
    tx_data[:name] = "set"

    tx_data.should have_key :values
    values = tx_data[:values]
    key    = values.first
    value  = values.last
    key.should have_key :name
    key.should have_key :value
    key[:name].should  eq "key"
    key[:value].should eq "foo"

    value.should have_key :name
    value.should have_key :value
    value[:name].should  eq "value"
    value[:value].should eq "bar"
  end

  specify "decode transaction (format: :new)" do
    tx = STATE[:tx]

    tx_data = Blocks::Transaction.read tx: tx # format is :new by default

    tx_data.should have_key :values
    values = tx_data[:values]
    values.should have_key :key
    values[:key].should eq "foo"
    values.should have_key :value
    values[:value].should eq "bar"
  end

  specify "decode transaction (format: :new)" do
    tx = STATE[:tx]

    tx_data = Blocks::Transaction.read tx: tx, format: :kv_hash

    tx_data.should have_key :values
    values = tx_data[:values]
    values.should have_key :foo
    values[:foo].should eq "bar"
  end

  specify "setup - updates last block with a predictable transaction" do
    value = { id: 1, name: "foo", hash: "baz" }
    value = Oj.dump value
    value = PrivacyEC.encrypt value
    RPC.set contract: :key_value, method: :set, params: ["documents:1", value]
  end

  specify "setup - gets TX (again)" do
    block = Blocks.all.last
    txs = block.fetch :transactions
    tx = txs.first
    STATE[:tx] = tx
  end

  specify "decode and decrypt transaction" do
    # block = Blocks.all.last
    # txs = block.fetch :transactions
    # tx = txs.first

    tx = STATE[:tx]

    tx_data = Blocks::Transaction.read tx: tx, format: :kv_hash_decrypted
    tx_data.should have_key :values
    values = tx_data[:values]

    values.should have_key :"documents:1"
    value = values[:"documents:1"]
    value.should be_a Hash
    value.should have_key :id
    value.should have_key :name
    value.should have_key :hash

    value[:id].should   eq 1
    value[:name].should eq "foo"
    value[:hash].should eq "baz"
  end

end
