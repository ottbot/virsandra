require 'spec_helper'

describe Virsandra::WhereQuery do
  subject(:query){ described_class.new(clause) }

  describe "#+" do
    let(:clause){ {id: [1,2]} }
    let(:other_query){ described_class.new(other_clause) }
    let(:other_clause){ {count: {lt_or_eq: 4}} }

    it "merge both where clauses with AND" do
      (query + other_query).should eq("WHERE id IN (1, 2) AND count <= 4")
    end

    it "should raise error when something else than WhereQuery is given" do
      expect{ query + 1}.to raise_error(Virsandra::InvalidQuery, "WhereQuery can be mereged only with other WhereQuery")
    end
  end

  describe "#to_s" do
    subject{ super().to_s }

    context "when clause given as string" do
      let(:clause){ "id='1' AND count=6" }

      it{ should eq("WHERE id='1' AND count=6")}
    end

    context "when clause given as hash" do
      let(:clause){ {id: '1', count: 6} }

      it{ should eq("WHERE id = '1' AND count = 6")}

      it "should convert each value" do
        Virsandra::CQLValue.should_receive(:convert).twice
        subject
      end
    end


    described_class::OPERATOR_MAPPING.reject{|key,value| key == :in}.each do |operator_name, operator|
      context "when any clause value given as hash" do
        let(:clause){ {id: '1', count: Hash[operator_name, 6]} }

        it{ should eq("WHERE id = '1' AND count #{operator} 6") }

        it "should convert each value" do
          Virsandra::CQLValue.should_receive(:convert).twice
          subject
        end
      end
    end

    context "when any clause value given as hash and hash key is :in" do
      let(:clause){ {id: '1', count: {:in => 6}} }

      it{ should eq("WHERE id = '1' AND count IN (6)")}

      it "should convert each value" do
        Virsandra::CQLValue.should_receive(:convert).twice
        subject
      end
    end

    context "when any clause value given as array" do
      let(:clause){ {id: '1', count: [2,3]} }

      it{ should eq("WHERE id = '1' AND count IN (2, 3)") }

      it "should convert each value" do
        Virsandra::CQLValue.should_receive(:convert).exactly(3).times
        subject
      end
    end
  end
end