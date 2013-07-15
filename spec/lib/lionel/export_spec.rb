require 'spec_helper'

describe Lionel::Export do

  describe "configuration" do
    before(:each) do
      subject.trello_board_id = "TRELLO_BOARD_ID"
      subject.google_doc_id = "GOOGLE_DOC_ID"
    end

    it {
      subject.data.should eq({
        trello_board_id: "TRELLO_BOARD_ID",
        google_doc_id: "GOOGLE_DOC_ID"
      })
    }

    it "can save the configuration data" do
      subject.configuration.should_receive(:save).with(subject.data)
      subject.save
    end

    it { subject.should be_configured }

    context "not configured" do
      before do
        subject.configuration.stub(trello_board_id: nil, google_doc_id: nil)
      end

      it { subject.trello_board_id = nil;
            subject.should_not be_configured }
      it { subject.google_doc_id = nil;
            subject.should_not be_configured }
      it { subject.trello_board_id = nil;
            subject.google_doc_id = nil;
            subject.should_not be_configured }
    end
  end
end
