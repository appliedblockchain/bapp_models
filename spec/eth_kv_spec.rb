require "spec_helper"

RSpec.describe EthKV do
  specify "get" do
    eth = EthKV.new
    eth.get "foo"         #=> "bar"
    eth["foo"]            #=> "bar"
  end

  specify "set" do
    eth = EthKV.new
    eth.set "foo", "baz"  #=> true
    eth["foo"] = "baz"
  end
end
