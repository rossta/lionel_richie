require 'spec_helper'

describe Lionel::TrelloAuthentication do
  it {
    subject.trello_key_url.should eq("https://trello.com/1/appKey/generate")
  }
  it {
    subject.trello_token_url("TOKEN").should eq("https://trello.com/1/authorize?key=TOKEN&name=LionelRichie&response_type=token&scope=read,write,account&expiration=never")
  }
  it { subject.app_name.should eq("LionelRichie") }

  describe "configuration" do
    before(:each) do
      subject.trello_key = "TRELLO_KEY"
      subject.trello_token = "TRELLO_TOKEN"
    end

    it {
      subject.data.should eq({
        trello_key: "TRELLO_KEY",
        trello_token: "TRELLO_TOKEN"
      })
    }

    it "can onfigure the Trello api" do
      subject.configure
      Trello.auth_policy.developer_public_key.should eq("TRELLO_KEY")
      Trello.auth_policy.member_token.should eq("TRELLO_TOKEN")
    end

    it "can save the configuration data" do
      subject.configuration.should_receive(:save).with(subject.data)
      subject.save
    end

    it { subject.should be_configured }

    context "not configured" do
      before do
        subject.configuration.stub(trello_key: nil, trello_token: nil)
      end

      it { subject.trello_key = nil;
            subject.should_not be_configured }
      it { subject.trello_token = nil;
            subject.should_not be_configured }
      it { subject.trello_key = nil;
            subject.trello_token = nil;
            subject.should_not be_configured }
    end
  end
end
