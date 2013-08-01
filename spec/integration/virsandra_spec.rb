require 'feature_helper'

describe "Virsandra", integration: true do

  it "return connection to server" do
    Virsandra.connection.should_not be_nil
  end

  it "allows to disconnect" do
    expect{ Virsandra.disconnect! }.not_to raise_error
  end
end