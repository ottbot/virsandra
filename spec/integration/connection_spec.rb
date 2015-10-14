require 'feature_helper'

describe "Connection", integration: true do
  let(:connection){ Virsandra.connection }

  context "errors" do
    it "re-connects when connection is lost" do
      create_companies_table
      values = %^#{SimpleUUID::UUID.new.to_guid},'Company name',10,'Founder',11111^
      connection.handle.close
      expect{ connection.execute("INSERT INTO companies (id, name, score, founder, founded) VALUES (#{values})") }.not_to raise_error
    end
  end
end
