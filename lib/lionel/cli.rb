module Lionel
  class CLI < Thor

    def initialize(*)
      @configuration = Lionel::Configuration.instance
      super
    end

    desc "authorize PROVIDER", "Allows application to request user authorization for provider (google|trello)"
    def authorize(provider)
      case provider
      when 'trello'
        auth = Lionel::TrelloAuthentication.new

        Launchy.open(auth.trello_key_url)
        auth.trello_key = ask "Enter trello key:"

        Launchy.open(auth.trello_token_url)
        auth.trello_token = ask "Enter trello token:"

        auth.save
      when 'google'
        auth = Lionel::GoogleAuthentication.new

        Launchy.open(auth.api_console_url)
        auth.google_client_id = ask("Enter your google client id:")
        auth.google_client_secret = ask("Enter your google client secret:")

        Launchy.open(auth.authorize_url)
        auth.retrieve_access_token ask("Enter your google key:")

        auth.save
      else
        "Provider not recognized: #{provider}"
      end
    end

    desc "export", "Saves Trello export to Google Docs"
    method_option "print", :aliases => "-p", :type => :boolean, :default => false, :desc => "Print results instead of saving them to Google Docs."
    def export
      export = Lionel::Export.new

      unless export.has_sources?
        export.trello_board_id = ask("Enter a trello board id to export from:")
        export.google_doc_id = ask("Enter a google doc id to export to:")
        export.save
      end

      export.authenticate

      welcome = "Trello? Is it me you're looking for?"
      say welcome
      say '=' * welcome.size

      export.download

      if options['print']
        export.rows.each { |row| say row }
      else
        export.upload
      end
    end

  end
end
