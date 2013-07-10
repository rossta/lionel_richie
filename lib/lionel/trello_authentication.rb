module Lionel
  class TrelloAuthentication

    attr_accessor :trello_key, :trello_token

    def trello_key
      @trello_key || ENV['TRELLO_KEY']
    end

    def trello_token
      @trello_token || ENV['TRELLO_TOKEN']
    end

    def configure
      Trello.configure do |c|
        c.developer_public_key  = trello_key
        c.member_token          = trello_token
      end
    end

    def commands
      [].tap do |commands|
        commands << trello_key_command
        commands << trello_token_command
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

    private

    def trello_key_command
      ENV['TRELLO_KEY'] = trello_key
      "export TRELLO_KEY=#{trello_key}"
    end

    def trello_token_command
      ENV['TRELLO_TOKEN'] = trello_token
      "export TRELLO_TOKEN=#{trello_token}"
    end

  end
end
