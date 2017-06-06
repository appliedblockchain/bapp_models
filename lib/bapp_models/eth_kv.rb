# exposes a key-value owner contract access by mimicking the redis API

require 'redis'

# use ethereum (key value / KVOwner contracts) as you use redis:
#
# R = Redis.new
# R.get "foo"         #=> "bar"
# R["foo"]            #=> "bar"
# R.set "foo", "baz"  #=> true
# R["foo"] = "baz"
#
# ETH = EthKV.new
# ETH.get "foo"         #=> "bar"
# ETH["foo"]            #=> "bar"
# ETH.set "foo", "baz"  #=> true
# ETH["foo"] = "baz"

module BAppModels
  class EthKV
    extend Forwardable

    # the default contract is KeyValueOwner (you're supposed to use KeyValueOwner w priv.) - contracts are near the application logic
    CONTRACT_DEFAULT = :key_value_owner

    # we use a shared contract to store indices and all the values that are modified "together" (log is enough) - there's no owner check in this case
    CONTRACT_SHARED  = :key_value

    ETH_KV_REDIS = ENV["ETH_KV_REDIS"] == "0"

    def_delegators :logger, :log

    def initialize(db: 1, shared: false)
      # object initialization...
      @contract = CONTRACT_DEFAULT
      @contract = CONTRACT_SHARED if shared

      # centralized / distributed (master-master replication) redis is used to get a list of all the available keys in the system - this list can be checked against a list reconstructed by

      @redis = Redis.new db: db if ETH_KV_REDIS

      @logger = self.class.logger
    end

    public

    def [](key)
      # log "GET: #{key.inspect}" if @log.extended
      begin
        value = RPC.get contract: @contract, method: :get, params: [key]
      rescue EthereumABI::ABI::DecodingError
        raise "ABI::DecodingError - Unable to decode value from ethereum - contract: #{@contract.inspect}, key: #{key.inspect} - EthereumABI::ABI::DecodingError"
      end
      log "GET result: #{value.inspect} (Base64)" if @log
      # optional gzip here
      return nil if value.empty?
      log "GET result: #{value.inspect}"
      value
    end

    def []=(key, value)
      # TODO: log "SET: #{key.inspect}: #{truncate value.inspect[0..100]}..." if @log
      log "SET: #{key.inspect}: #{value.inspect[0..100]} #{value.inspect.size > 99 ? "(...)" : "" }" if @log
      @redis[key] = "1" if ETH_KV_REDIS
      value = value.to_s
      # optional gzip here
      log "SET (raw): #{key.inspect}: #{value}" if @log
      RPC.set contract: @contract, method: :set, params: [key, value]
      true
    end

    def owner(key)
      RPC.get contract: @contract, method: :get_owner, params: [key]
    end

    def keys(pattern="*")
      raise "EthKV #keys method is disabled - please unset your environment variable ETH_KV_REDIS" unless ETH_KV_REDIS
      @redis.keys pattern
    end

    alias :get :"[]"
    alias :set :"[]="

    def log(message)
      @logger.log message
    end

    private

    def self.logger
      if defined? Log
        Log.new :eth_kv
      else
        return @@logger if defined? @@logger
        require 'logger'
        @@logger = Logger.new ENV["LOGGER"] || STDOUT
        def @@logger.log(message); info message; end
        @@logger
      end
    end

  end
end
