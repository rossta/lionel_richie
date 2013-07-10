module Lionel
  class GoogleAuthentication

    def call
      access_token = if refresh_token
        request_refreshed_access_token
      else
        request_new_access_token
      end

      [].tap do |commands|
        ENV['GOOGLE_TOKEN'] = access_token.token
        commands << "export GOOGLE_TOKEN=#{access_token.token}"

        ENV['GOOGLE_REFRESH_TOKEN'] = access_token.refresh_token
        commands << "export GOOGLE_REFRESH_TOKEN=#{access_token.refresh_token}"
      end
    end

    def refresh
      call
    end

    def request_refreshed_access_token
      access_token = OAuth2::AccessToken.from_hash(client,
          {:refresh_token => refresh_token, :expires_at => 36000})
      access_token.refresh! # returns new access_token
    end

    # Redirect the user to authorize_url and get authorization code from redirect URL.
    def request_new_access_token
      Launchy.open authorize_url

      puts "Enter your google key:"
      authorization_code = gets.strip
      client.auth_code.get_token(authorization_code,
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob")
    end

    def authorize_url
      client.auth_code.authorize_url(
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
        :scope =>
            "https://docs.google.com/feeds/ " +
            "https://docs.googleusercontent.com/ " +
            "https://spreadsheets.google.com/feeds/")
    end

    def client
      @client ||= OAuth2::Client.new(client_id, client_secret,
        :site => "https://accounts.google.com",
        :token_url => "/o/oauth2/token",
        :authorize_url => "/o/oauth2/auth")
    end

    def refresh_token
      ENV['GOOGLE_REFRESH_TOKEN']
    end

    def client_id
      @client_id ||= ENV['GOOGLE_CLIENT_ID'] || begin
        puts "Enter your google client id:"
        ENV['GOOGLE_CLIENT_ID'] = gets.strip
      end
    end

    def client_secret
      @client_secret ||= ENV['GOOGLE_CLIENT_SECRET'] || begin
        puts "Enter your google client secret:"
        ENV['GOOGLE_CLIENT_SECRET'] = gets.strip
      end
    end

  end
end
