module Lionel
  class CLI < Thor

    desc "authorize", "Allows application to request user authorization"
    def authorize
      commands = []

      if yes? "Authorize for Trello?"
        auth          = Lionel::TrelloAuthentication.new

        Launchy.open(auth.trello_key_url)
        auth.trello_key = ask "Enter trello key:"

        Launchy.open(auth.trello_token_url)
        auth.trello_token  = ask "Enter trello token:"

        commands += auth.commands
      end

      # Google Auth
      if yes? "Authorize for Google?"
        auth = Lionel::GoogleAuthentication.new

        Launchy.open(auth.authorize_url)
        auth.retrieve_access_token ask("Enter your google key:")

        commands += auth.commands
      end

      if commands.any?
        say "Run the following:\n"
        commands.each { |command| say command }
      end
    end

    desc "export", "Saves Trello export to Google Docs"
    method_option "print", :aliases => "-p", :type => :boolean, :default => false, :desc => "Print results instead of saving them to Google Docs."
    def export
      export = Lionel::Export.new
      export.authenticate

      welcome = "Trello? Is it me you're looking for?"
      say welcome
      say "#{'=' * welcome.size}\n"

      export.load

      if options['print']
        export.rows.each { |row| say row }
      else
        export.save
      end
    end

    private

    def save_to_google?
      !!@save_to_google
    end

  end
end
