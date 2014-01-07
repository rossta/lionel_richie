require 'spec_helper'

describe Lionel::ExportBuilder do
  let(:builder) { described_class.new }

  describe "configure" do
    it "accepts block for column" do
      builder.configure do
        A { "123" }
      end

      builder.columns["A"].call.should eq("123")
    end

    it "accepts hard-coded value" do
      builder.configure do
        A "123"
      end

      builder.columns["A"].should eq("123")
    end

    it "raises error if not a column name (only letters)" do
      expect { builder.configure { x123 "123" } }.to raise_error(Lionel::ColumnConfigurationError)
    end
  end
end
