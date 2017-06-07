require "spec_helper"

RSpec.describe EthModel do

  def db_clear
    Redis.new(db: 11).flushdb
    Redis.new(db: 12).flushdb
  end

  class Document < EthModel
    eth_model

    attribute :name,      String
    attribute :contents,  String
  end

  before :all do
    db_clear
  end

  specify "EthModel" do
    Document.new().should be_a BAppModels::EthModel
    # include ethmodel
  end

  specify "model attributes" do
    doc = Document.new
    doc.name.should be_nil
    doc.name = "test"
    doc.name.should eq "test"
    doc.save
    doc.name.should eq "test"

    Document.count.should be 1

    doc = Document.get  1
    doc.name.should eq "test"

    doc = Document.get_raw 1
    doc.name.should eq "!@!!"
  end

end
