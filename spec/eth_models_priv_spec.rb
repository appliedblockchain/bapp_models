require "spec_helper"

RSpec.describe EthModel do

  class Document < EthModel
    eth_model

    attribute :name,      String
    attribute :contents,  String
  end

  before :all do
    Redis.new(db: 11).flushdb
    Redis.new(db: 12).flushdb
  end

  specify "EthModel" do
    Document.new().should be_a BAppModels::EthModel
    # include ethmodel
  end

  specify "model attributes" do
    doc = Document.new
    doc.save


  end

end
