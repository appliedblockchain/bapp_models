# BAppModels

BAppModels contains an Ethereum model definition library and a KeyValue API for accessing ethereum easily from your app. BAppModels depends on appliedblockchain/ethereum RPC library.

You can use BAppModel's two APIs / models flavours:

- EthModel
- EthKV

## EthModel

EthModel has an API which is very similar to the popular ActiveModel api, except that every time you trigger a save, the data is stored in Ethereum.

EthModel provides you with a simple CRU (crud without delete - create read update)

## Default CRU API

```rb
# replace Model with the name of your model

Model.get 1 #=> returns an object instance (gets it from ethereum)

Model.all #=> returns an array of Model object instances

Model.create({}) #=> creates an entry in ethereum

Model.update(1, {}) #=> updates a record in ethereum
```

### Model definition

```rb


class Document < EthModel
  eth_model

  attribute :name,      String
  attribute :contents,  String
  attribute :hash,      String

  def calc_hash
    # probably you want to do something like: Digest::SHA.hexdigest content (probably in initialize)
    self.hash = contents.reverse
  end
end
```

### Sample Model Usage

```rb
doc = Document.new name: "Foo", contents: "Bar123"
doc.name      #=> "foo"
doc.calc_hash #=> "..."
doc.save      # (data should be saved into ethereum)
# at the moment let's use this version:
doc.update(doc.attributes)

# you can retrieve data from Ethereum
#
doc = Document.get 1
doc.name #=> "foo"
```

EthModel is an extension built on top of Virtus. Thanks to Virtus we can add new features like relationsips, constraints, validations, observable hooks/attributes and many more features easily in the future.

Refer to Virtus documentation (https://github.com/solnic/virtus) for more infos on attributes/types/etc.




## Default CRU API (w/ external key)

```rb
# replace Model with the name of your model

Model.get id: 1 #=> returns an object instance (gets it from ethereum) - note this differs from the default one so you can override the model to pass finders ( for example passing { name: "" }, so you don't need to implement find_by_name or similar methods )

Model.all #=> returns an array of Model object instances

Model.create({}) #=> creates an entry in ethereum

# the default update is the .save in the model itself

object = Model.get id: 1
object.name "Foobar"
object.save # this calls an update of the model data
```

On the contract side we use these kind of methods (basically a key/value API):


```js
getFull()
getValue()

create()
update()
```


We always pass to every method the 3 required **ECVerify** arguments:

```js

// client:
hash = computeHash hash
signature = sign(hash)

// chain:
(hash, signature, address)

```

essentially verifies that the owner of the data (because the signature matches the hash of the message, we can verify)

---

Please see `appliedblockchain/cygnetise_models` and `appliedblockchain/cygnetise_contracts` repositories to see a live example of this API.




## EthKV

EthKV is the KeyValue API to the KeyValue (shared) / KeyValueOwner (owned) Ethereum contracts.

EthKV mimics the Redis API which let you test against a very fast "fake" Ethereum in dev/test environments where you need performance and you don't care about having Ethereum (which you probably need to install / configure / setup / reset / redeploy contracts / etc... ).

Take a look at the simple straightforward API (compared to the redis one):

```rb
R = Redis.new
R.get "foo"         #=> "bar"
R["foo"]            #=> "bar"
R.set "foo", "baz"  #=> true
R["foo"] = "baz"

ETH = EthKV.new
ETH.get "foo"         #=> "bar"
ETH["foo"]            #=> "bar"
ETH.set "foo", "baz"  #=> true
ETH["foo"] = "baz"
```

Remember that if you need to call Ethereum contract methods directly you can use the RPC api straight away - take a look here for more infos: https://github.com/appliedblockchain/ethereum


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bapp_models'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bapp_models

## Usage

Please read the instructions above (before the installation instructions) or look at the specs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb` and push the gem on github.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bapp_models.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
