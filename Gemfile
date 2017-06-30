source 'https://rubygems.org'

# Specify your gem's dependencies in bapp_models.gemspec
gemspec

group :test do
  if ENV["TEST_LINUX"] == "1"
    gem "digest-sha3", git: "https://github.com/steakknife/digest-sha3-ruby.git"
  end
  gem "ethereum", git: "https://#{ENV["GH_TOKEN"]}@github.com/appliedblockchain/ethereum"
end
