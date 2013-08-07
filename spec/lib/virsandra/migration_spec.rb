require 'spec_helper'

describe Virsandra::Migration do
  let(:files){ [] }
  subject(:migration){ described_class.new(files) }

  it "should initialize new migration" do
    expect{ migration }.not_to raise_error
  end

  describe "#migrate_up" do
    let(:files){ ['/path/to/file/20130809143329_file_one.rb', '/path/to/file/20130809143324_file_two.rb'] }
    let(:file_one_class){ double("file one class") }
    let(:file_two_class){ double("file two class") }
    let(:file_one){ double("file one") }
    let(:file_two){ double("file two") }

    before do
      stub_const("FileOne", file_one_class)
      stub_const("FileTwo", file_two_class)
    end

    it "should migrate up all given files" do
      Kernel.should_receive(:require).with(files.first)
      Kernel.should_receive(:require).with(files.last)
      file_one_class.should_receive(:new).and_return(file_one)
      file_two_class.should_receive(:new).and_return(file_two)
      file_two.should_receive(:up).ordered
      file_one.should_receive(:up).ordered
      migration.migrate_up
    end
  end
end