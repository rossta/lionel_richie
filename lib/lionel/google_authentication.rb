module Lionel
  class GoogleAuthentication
    include Configurable

    attr_reader :access_token
    config_accessor :google_client_id, :google_client_secret

    def data
      raise "No access token" unless access_token
      {
        google_token: access_token.token,
        google_refresh_token: access_token.refresh_token,
        google_client_id: google_client_id,
        google_client_secret: google_client_secret
      }
    end

    def retrieve_access_token(authorization_code)
      @access_token = client.auth_code.get_token(authorization_code,
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob")
    end

    def refresh
      return false unless refresh_token

      current_token = OAuth2::AccessToken.from_hash(client,
          {:refresh_token => refresh_token, :expires_at => 36000})
      @access_token = current_token.refresh! # returns new access_token
    end

    def authorize_url
      client.auth_code.authorize_url(
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
        :scope =>
            "https://docs.google.com/feeds/ " +
            "https://docs.googleusercontent.com/ " +
            "https://spreadsheets.google.com/feeds/")
    end

    def api_console_url
      "https://code.google.com/apis/console"
    end

    private

    def client
      @client ||= OAuth2::Client.new(google_client_id, google_client_secret,
        :site => "https://accounts.google.com",
        :token_url => "/o/oauth2/token",
        :authorize_url => "/o/oauth2/auth")
    end

    def refresh_token
      @refresh_token || configuration.google_refresh_token
    end

  end
end
