require 'feature_helper'

describe "Virsandra", integration: true do

  it "return connection to server" do
    Virsandra.connection.should_not be_nil
  end

  it "allows to disconnect" do
    Virsandra.disconnect!
    Virsandra.should_not be_connected
  end
end
