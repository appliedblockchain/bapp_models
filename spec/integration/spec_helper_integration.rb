require_relative "../spec_helper"

path = File.expand_path "../../../", __FILE__

ETH_CONFIG_DIR = "#{path}/spec/integration/config"

Bundler.require :default, :test

require_relative '../../lib/blocks/transaction'

puts `cp #{path}/../bapp_parity/config/contracts/*.json #{ETH_CONFIG_DIR}/contracts/`

RPC = Ethereum::Eth.new
RPC.start!
