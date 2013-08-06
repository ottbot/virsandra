require 'feature_helper'

describe "Virsandra", integration: true do

  it "return connection to server" do
    Virsandra.connection.should_not be_nil
  end

  it "allows to disconnect" do
    Virsandra.connection.should_receive(:disconnect!).and_call_original
    Virsandra.disconnect!
  end
end