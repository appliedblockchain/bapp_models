require "bapp_models/version"
require "bapp_models/eth_kv"
require "bapp_models/eth_models"

module BAppModels
  # placeholder
  #
  # define global gem/module behaviour here
end

# keychain initialization code
#
Keychain.setup

raise "Error creating the ~/.keychain directory for user #{`whoami`} - aborting - make sure your user has permission to do so or set KEYCHAIN_DEFAULT_DIR to another path" unless Dir.exists? File.expand_path Keychain.keychain_dir
