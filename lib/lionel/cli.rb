module Lionel
  class CLI < Thor
    desc "authorize PROVIDER", "Allows application to request user authorization for provider (google|trello)"
    method_option "new-client", :aliases => "-n", :type => :boolean,
      :default => false, :desc => "Set new google client credentials."
    def authorize(provider)
      case provider
      when 'trello'
        auth = Lionel::TrelloAuthentication.new

        if options['new-client'] || !auth.configured?
          Launchy.open(auth.trello_key_url)
          auth.trello_key = ask "Enter trello key:"

          Launchy.open(auth.trello_token_url)
          auth.trello_token = ask "Enter trello token:"

          auth.save_configuration
        else
          say "Trello is already configured. Run 'lionel authorize trello -n' to reset."
        end
      when 'google'
        auth = Lionel::GoogleAuthentication.new

        if options['new-client'] || !auth.configured?
          Launchy.open(auth.api_console_url)
          auth.google_client_id = ask("Enter your google client id:")
          auth.google_client_secret = ask("Enter your google client secret:")
        end

        Launchy.open(auth.authorize_url)
        auth.retrieve_access_token ask("Enter your google key:")

        auth.save_configuration
      else
        "Provider not recognized: #{provider}"
      end
    end

    desc "export", "Saves Trello export to Google Docs"
    method_option "print", :aliases => "-p", :type => :boolean, :default => false, :desc => "Print results instead of saving them to Google Docs."
    method_option "trello-board-id", :aliases => "-t", :type => :string, :default => nil, :desc => "Specify the source Trello board id."
    method_option "google-doc-id", :aliases => "-g", :type => :string, :default => nil, :desc => "Specify the target Google doc id."
    method_option "save", :aliases => "-s", :type => :string, :default => true, :desc => "Save the command line ids as the default configuration."
    method_option "filter", :aliases => "-f", :type => :string, :default => 'open-lists', :desc => "Possible values: open-cards, open-lists."
    method_option "configuration", :aliases => "-c", :type => :string, :default => nil, :desc => "Path to Lionelfile configuration"
    def export
      lionel_file = options['configuration'] || './Lionelfile'
      eval(File.read(lionel_file)) if File.exists?(lionel_file)

      export = Lionel::Export.new(options)

      if options['google-doc-id']
        export.google_doc_id = options['google-doc-id']
      elsif !export.google_doc_id
        export.google_doc_id = ask("Enter a google doc id to export to:")
      end

      if options['trello-board-id']
        export.trello_board_id = options['trello-board-id']
      elsif !export.trello_board_id
        export.trello_board_id = ask("Enter a trello board id to export from:")
      end

      export.save_configuration if options['save']

      begin
        export.authenticate
      rescue GoogleDrive::Error, GoogleDrive::AuthenticationError
        @google_attempts ||= 0
        @google_attempts += 1
        Lionel::GoogleAuthentication.new.refresh
        if @google_attempts < 2
          retry
        else
          invoke :authorize, ['google'], {}
        end
      rescue Trello::Error, Trello::InvalidAccessToken
        invoke :authorize, ['trello'], {}
      ensure
        export.authenticate
      end

      welcome = "Trello? Is it me you're looking for?"
      say welcome
      say '=' * welcome.size

      export.process
    end

  end
end
