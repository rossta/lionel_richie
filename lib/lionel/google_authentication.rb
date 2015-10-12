require "google/api_client"

module Lionel
  class GoogleAuthentication
    include Configurable

    attr_accessor :access_token, :refresh_token
    attr_writer :client
    config_accessor :google_client_id, :google_client_secret

    def data
      raise "No access token" unless access_token
      {
        google_token: access_token,
        google_refresh_token: refresh_token,
        google_client_id: google_client_id,
        google_client_secret: google_client_secret
      }
    end

    def retrieve_access_token(authorization_code)
      authorization.code = authorization_code
      authorization.fetch_access_token!
      @access_token = authorization.access_token
      @refresh_token = authorization.refresh_token
    end

    def refresh
      return false unless refresh_token && access_token

      authorization.access_token = access_token
      authorization.refresh_token = refresh_token
      authorization.refresh!

      @access_token = authorization.access_token
    end

    def authorize_url
      authorization.authorization_uri
    end

    def api_console_url
      "https://code.google.com/apis/console"
    end

    def authorization
      @authorization ||= begin
                           auth = client.authorization
                           auth.client_id = google_client_id
                           auth.client_secret = google_client_secret
                           auth.scope = scopes
                           auth.expires_in = one_year
                           auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
                           auth
                         end
    end

    def client
      @client ||= Google::APIClient.new(auto_refresh_token: true)
    end

    private

    def build_client
      auth = client.authorization
      auth.client_id = google_client_id
      auth.client_secret = google_client_secret
      auth.scope = scopes
      auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
      client
    end

    def refresh_token
      @refresh_token || configuration.google_refresh_token
    end

    def scopes
      [
        "https://docs.google.com/feeds/",
        "https://docs.googleusercontent.com/",
        "https://spreadsheets.google.com/feeds/"
      ]
    end

    def one_year # in seconds
      60*60*24*36
    end

  end
end
