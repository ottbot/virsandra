require 'spec_helper'

describe Virsandra::ColumnsQuery do
  subject{ described_class.new }

  describe "#to_s" do
    subject{ super().to_s }

    it{ should eq("")}
  end

  describe "#add" do
    subject{ super().add("id uuid").add("name text").to_s }

    it{ should eq("id uuid, name text") }
  end
end