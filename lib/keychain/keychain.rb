require 'digest'
require 'bitcoin'

# Keypair keychain

module RC
class Keychain

  attr_reader :public_key, :address, :private_key

  def initialize(private_key = nil, key_path: nil)
    @key_path    = key_path
    @private_key = private_key || load_or_generate_key
    @public_key  = derive_public  priv_key: @private_key
    @address     = derive_address pub_key:  @public_key
  end

  def load_or_generate_key
    return self.class.generate unless @key_path

    if key_exists?
      key_load
    else
      key = self.class.generate
      key_save key
    end
  end

  private

  def key_exists?
    File.exists? @key_path
  end

  def key_load
    key = File.read @key_path
    key.strip!
    # TODO: extract error
    raise "KeyEmptyError - Keypair tried to load a blank key" if key.empty?
    key
  end

  def key_save(key)
    File.open @key_path, "w" do |file|
      file.write key
    end
    key
  end

  public

  def self.generate
              # uses openssl internally
    priv, _ = Bitcoin::generate_key
    priv
  end

  def sign_data(data, to: nil)
    tx = Transaction.new keypair: self
    tx.data = data
    tx.to   = to
    tx.sign_and_propagate!
    tx
  end

  def sign(data)
    private_key = Bitcoin.open_key @private_key
    Bitcoin.sign_data private_key, data
  end

  def verify(signature:, message:)
    Bitcoin.verify_message(@address, signature, message)
  end


  private

  def derive_public(priv_key:)
    Bitcoin::OpenSSL_EC.regenerate_key(priv_key)[1]
  end

  def derive_address(pub_key:)
    Bitcoin.hash160_to_address Bitcoin.hash160 pub_key
  end

end
end

# notes: moving forward -> https://github.com/appliedblockchain/bapp3/blob/master/projects/futures/lib/keypair_ext.rb (hd keys for pseudonimity - #privacy)
