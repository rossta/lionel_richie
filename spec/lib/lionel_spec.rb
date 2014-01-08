require 'spec_helper'

describe Lionel do
  TestCard = Struct.new(:id, :name, :url)

  describe "self.export" do
    it "configures the export builder" do
      card = TestCard.new(123, "Testing cards", "http://example.com")

      Lionel.export do
        A { id }
        B { name }
        C { url }
      end

      builder = Lionel::Export.builder

      card.instance_eval(&builder.columns["A"]).should eq(123)
      card.instance_eval(&builder.columns["B"]).should eq("Testing cards")
      card.instance_eval(&builder.columns["C"]).should eq("http://example.com")
    end
  end
end
