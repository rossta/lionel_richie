require 'spec_helper'

describe Lionel::GoogleAuthentication do
  let(:access_token) {
    double('OAuth2::AccessToken', token: "GOOGLE_TOKEN", refresh_token: "GOOGLE_REFRESH_TOKEN")
  }

  it {
    subject.api_console_url.should eq("https://code.google.com/apis/console")
  }

  describe "configuration" do
    before(:each) do
      subject.access_token = access_token
      subject.google_client_id = "GOOGLE_CLIENT_ID"
      subject.google_client_secret = "GOOGLE_CLIENT_SECRET"
    end

    it {
      subject.data.should eq({
        google_token: "GOOGLE_TOKEN",
        google_refresh_token: "GOOGLE_REFRESH_TOKEN",
        google_client_id: "GOOGLE_CLIENT_ID",
        google_client_secret: "GOOGLE_CLIENT_SECRET"
      })
    }

    it "can save the configuration data" do
      subject.configuration.should_receive(:save).with(subject.data)
      subject.save_configuration
    end

    it "creates new Oauth2 client" do
      OAuth2::Client.should_receive(:new).with(
        "GOOGLE_CLIENT_ID", "GOOGLE_CLIENT_SECRET",
        :site => "https://accounts.google.com",
        :token_url => "/o/oauth2/token",
        :authorize_url => "/o/oauth2/auth")
      subject.client
    end

    it { subject.should be_configured }

    context "not configured" do
      before do
        subject.configuration.stub(google_client_id: nil, google_client_secret: nil)
      end

      it { subject.google_client_id = nil;
            subject.should_not be_configured }
      it { subject.google_client_secret = nil;
            subject.should_not be_configured }
      it { subject.google_client_id = nil;
            subject.google_client_secret = nil;
            subject.should_not be_configured }
    end
  end

  describe "oauth2" do
    let(:auth_code) { double('OAuth2::AuthCode', :authorize_url => "http://example.com") }
    let(:client) { double('OAuth2::Client', auth_code: auth_code) }

    before(:each) do
      subject.google_client_id = "GOOGLE_CLIENT_ID"
      subject.google_client_secret = "GOOGLE_CLIENT_SECRET"
      subject.client = client
    end

    it "retrieves oauth2 authorize_url" do
      auth_code.should_receive(:authorize_url).with(
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
        :scope =>
            "https://docs.google.com/feeds/ " +
            "https://docs.googleusercontent.com/ " +
            "https://spreadsheets.google.com/feeds/")
      subject.authorize_url
    end
  end
end
