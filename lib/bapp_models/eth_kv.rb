# exposes a key-value owner contract access by mimicking the redis API

require 'redis'
require 'base64'

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
      value = get_value key: key
      log "GET result: #{value.inspect} (Base64)" if @log
      value = get_value_gzip value if ENV["GZIP"] == "1"
      return nil if value.empty?
      log "GET result: #{value.inspect}" if @log
      value
    end

    def []=(key, value)
      log "SET: #{key.inspect}: #{value.inspect[0..100]} #{value.inspect.size > 99 ? "(...)" : "" }" if @log
      @redis[key] = "1" if ETH_KV_REDIS
      value = value.to_s
      value = set_value_gzip value if ENV["GZIP"] == "1"
      log "SET (raw): #{key.inspect}: #{value}" if @log

      length = value_length value: value
      puts "LEN: #{length}" if @log
      set_value key: key, value: value, length: length

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

    # enables key-value w/ multi-key (if the value is too big it will be saved in multiple key-value pairs)
    def kv_multi?
      KV_MULTI
    end

    # SET (sendTransaction)

    TX_SIZE = 400  # CONSERVATIVE

    if RACK_ENV == "test"
      send :remove_const, :TX_SIZE
      TX_SIZE = 200
    end

    # TX_SIZE = 1000 # TODO: recheck, the limit should be > 1000 chars
    # TX_SIZE = 3000 # probably 3k is too much for gas ~5 mil

    def set_value(key:, value:, length:)
      puts "SET val - #{key.inspect}: #{value.inspect}" if @log
      if length == 1 || !kv_multi?
        eth_set_value key: key, value: value
      else
        eth_set_value key: key, value: "<#{length}>"

        values = value.scan /.{1,#{TX_SIZE}}/
        values.each_with_index do |value, idx|
          eth_set_value key: "#{key}:multi_kv:#{idx}", value: value
        end
      end
    end

    def value_length(value:)
      length = ( value.size.to_f / TX_SIZE ).ceil
      raise "TOOD: remove the cap - right now you can't set more than 100 KVs for a single value" if length > 100
      length == 0 ? 1 : length
    end


    # GET

    def get_value(key:)
      begin
        value = eth_get_value key: key
      rescue EthereumABI::ABI::DecodingError
        raise "ABI::DecodingError - Unable to decode value from ethereum - contract: #{@contract.inspect}, key: #{key.inspect} - EthereumABI::ABI::DecodingError"
      end

      if kv_multi? && value && value[0] == "<"
        get_value_multi key: key, multi: value
      else
        value
      end
    end

    def get_value_multi(key:, multi:)
      get_each_value = -> (values, key) {
        value = eth_get_value key: key
        values << value
        values
      }

      multi = multi.match /<(?<multi>\d+)>/
      multi = multi[:multi]
      multi = multi.to_i

      key    = "#{key}:multi_kv"
      values = []

      0.upto(multi-1) do |current|
        values = get_each_value.(values, "#{key}:#{current}")
      end

      values.join ""
    end

    def eth_get_value(key:)
      puts "GET: #{key.inspect}" if @log
      value = RPC.get contract: @contract, method: :get, params: [key]
      puts "value: #{value.inspect}" if @log
      value
    end

    def eth_set_value(key:, value:)
      puts "SET: #{key.inspect}: #{value.inspect}" if @log
      RPC.set contract: @contract, method: :set, params: [key, value]
    end

    # gzip

    def get_value_gzip(value)
      return nil if value.empty?
      value = Base64.strict_decode64 value
      return nil if value.empty?
      Zlib::Inflate.inflate value
    end

    def set_value_gzip(value)
      value = Zlib::Deflate.deflate value
      Base64.strict_encode64 value
    end

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
