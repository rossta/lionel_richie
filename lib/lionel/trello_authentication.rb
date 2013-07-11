module Lionel
  class TrelloAuthentication
    include Configurable

    config_accessor :trello_key, :trello_token

    def data
      {
        trello_key: trello_key,
        trello_token: trello_token
      }
    end

    def configure
      Trello.configure do |c|
        c.developer_public_key  = trello_key
        c.member_token          = trello_token
      end
    end

    def trello_key_url
      "https://trello.com/1/appKey/generate"
    end

    def trello_token_url(key = trello_key)
      "https://trello.com/1/authorize?key=#{key}&name=#{app_name}&response_type=token&scope=read,write,account&expiration=never"
    end

    def app_name
      "LionelRichie"
    end

  end
end
