class Blocks

  module Transaction

    class NilTransactionDetails
    end

    class AlienContractDeployedException < Exception
    end

    def read(tx:, format: :new)
      input     = tx["input"]
      method_id = input[0..9]
      input_raw = tx["input"][10..-1]
      meth = tx_method_details_safe input: input_raw, method_id: method_id
      meth[:values] = case format
      when :original
        meth[:values]
      when :new
        rearrange_values meth[:values]
      when :kv_hash
        rearrange_values_kv meth[:values]
      when :kv_hash_decrypted
        unless meth[:deployment]
          values = rearrange_values_kv meth[:values]
          if KV_MULTI
            kv_multi_get_and_decrypt values: values
          else
            # just decrypt
            decrypt_tx_values values
          end
        else
          NilTransactionDetails.new
        end
      else
        raise "Block::Transaction#read :format does NOT match - format: #{format.inspect} - accepted values: [:original, :new, :kv_hash, :kv_hash_decrypted]"
      end
      meth
    end

    module_function :read

    private

    module ModuleMethods

      include Ethereum::Formatting

      def kv_multi_get_and_decrypt(values:)
        # assume we get only 1 key/value pair
        key   = values.keys.first
        value = values.values.first

        return({ key => NilTransactionDetails.new }) if key =~ /:multi_kv:[1-9]\d*$/
        # value = fetch_multi values: values

        values = kv_multi_get key: key
        value  = values.join ""
        decrypt_tx_values( key => value )
      end

      def kv_multi_get(key:)
        # TODO
        ["{}"]
      end

      def tx_method_details(input:, method_id:)
        values   = input

        meth = nil
        interface = RPC.interface
        interface.each do |name, contract|
          contract[:setters].each do |setter|
            if setter["methodId"] == method_id
              meth = setter
              inputs = meth["inputs"]
              ctr = {
                name:       contract[:name],
                class_name: contract[:class_name],
              }
              meth[:contract] = ctr
              meth[:values]   = extract_values values, inputs: inputs
              break
            end
          end
        end

        if method_id == "0x60606040"
          {
            method_id: method_id,
            deployment: true
          }
        elsif meth
          {
            method_id: method_id,
            name:      meth["name"],
            values:    meth[:values],
            contract:  meth[:contract],
          }
        else
          raise method_id
          AlienContractDeployedException.new("nil object method not found")
        end
      end

      def extract_values(values, inputs:)
        vals = transform_outputs_safe values, outputs: inputs

        inputs.map.with_index do |input, idx|
          {
            name:  input["name"],
            value: vals[idx],
          }
        end
      end

      # safe methods (rescue exception and return null-objects)

      def tx_method_details_safe(input:, method_id:)
        tx_method_details input: input, method_id: method_id
      # TODO: rescue errors, provide a nil object
      end

      def transform_outputs_safe(values, outputs:)
        transform_outputs values, outputs: outputs
      # TODO: rescue (check above)
      end

      def rearrange_values(values)
        hash = {}
        values.each do |value|
          puts value.class
          puts value
          key = value.fetch :name
          hash[key.to_sym] = value.fetch :value
        end
        hash
      end

      def rearrange_values_kv(values)
        values = rearrange_values values
        key = values.fetch :key
        hash = {}
        hash[key.to_sym] = values.fetch :value
        hash
      end

      def decrypt_tx_values(hash)
        key   = hash.keys.first
        value = hash.values.first
        value = decrypt_tx_value_safe value
        value = parse_json value
        hash[key] = value
        hash
      end

      def decrypt_tx_value_safe(value)
        decrypt_tx_value value
      # TODO: raise (and catch) a more specific exception from PrivacyEC#decode_hex & #encode_hex
      rescue TypeError
        "{}"
      end

      def decrypt_tx_value(value)
        PrivacyEC.decrypt value
      end

      def parse_json(value)
        Oj.load value
      # rescue TODO: rescue the right exception (Oj::ParseError?)
      end

    end

    extend ModuleMethods

  end

end
