require "bundler/setup"
require "bapp_models"

require_relative 'stubs/eth_kv_stub'

include BAppModels

require_relative 'stubs/eth_models_stub'


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should]
  end
end
