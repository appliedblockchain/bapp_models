require "spec_helper"

RSpec.describe BAppModels do
  it "has a version number" do
    expect(BAppModels::VERSION).not_to be nil
  end
end
