require 'spec_helper'

describe Virsandra::Migration do
  let(:files){ [] }
  let(:options){ {} }
  let(:migration_table){ double("migration table", versions: [], mark_as_migrated: nil) }
  subject(:migration){ described_class.new(files, options) }

  before do
    Virsandra::Migrations::Table.stub(:new => migration_table)
  end

  it "should initialize new migration" do
    expect{ migration }.not_to raise_error
  end

  describe "migration table" do
    it "should create migration table" do
      Virsandra::Migrations::Table.should_receive(:new).with(nil)
      migration
    end

    context "with given keyspace" do
      let(:keyspace){ double("keyspace") }
      let(:options){ {keyspace: keyspace} }

      it "should create migration with given keyspace" do
        Virsandra::Migrations::Table.should_receive(:new).with(keyspace)
        migration
      end
    end
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

    it "should mark files as migrated" do
      Kernel.should_receive(:require).with(files.first)
      Kernel.should_receive(:require).with(files.last)
      file_one_class.should_receive(:new).and_return(file_one)
      file_two_class.should_receive(:new).and_return(file_two)
      file_one.stub(:up)
      file_two.stub(:up)
      migration_table.should_receive(:mark_as_migrated).with("20130809143324").ordered
      migration_table.should_receive(:mark_as_migrated).with("20130809143329").ordered
      migration.migrate_up
    end

    context "with existing files" do
      let(:versions){ ["20130809143329"] }
      let(:migration_table){ double("migration table", versions: versions, mark_as_migrated: nil)}

      it "migrates only new files" do
        Kernel.should_not_receive(:require).with(files.first)
        Kernel.should_receive(:require).with(files.last)
        file_one_class.should_not_receive(:new)
        file_two_class.should_receive(:new).and_return(file_two)
        file_two.should_receive(:up)
        migration.migrate_up
      end
    end

    context "with given version number" do
      let(:files){ super() + ['/path/to/file/20130809143325_file_three.rb'] }
      let(:options){ {version: "20130809143324"} }

      it "should migrate only given version" do
        Kernel.should_receive(:require).with(files[1])
        file_one_class.should_not_receive(:new)
        file_two_class.should_receive(:new).and_return(file_two)
        file_two.should_receive(:up)
        migration.migrate_up
      end
    end
  end
end