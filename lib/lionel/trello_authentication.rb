module Lionel
  class TrelloAuthentication

    attr_reader :trello_key, :trello_token

    def call
      [].tap do |commands|
        commands << get_trello_key
        commands << get_trello_token
      end
    end

    private

    def get_trello_key
      Launchy.open "https://trello.com/1/appKey/generate"

      puts "Enter your trello key:"
      @trello_key = gets.strip

      ENV['TRELLO_KEY'] = trello_key
      "export TRELLO_KEY=#{trello_key}"
    end

    def get_trello_token
      Launchy.open "https://trello.com/1/authorize?key=#{trello_key}&name=LionelRichie&response_type=token&scope=read,write,account&expiration=never"

      puts "Enter your trello token"
      @trello_token = gets.strip

      ENV['TRELLO_TOKEN'] = trello_token
      "export TRELLO_TOKEN=#{trello_token}"
    end

  end
end
