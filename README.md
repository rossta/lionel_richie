# LionelRichie

Trello? Is it me you're looking for?

LionelRichie is a script for exporting Trello data to Google Docs.

## Installation

Add this line to your application's Gemfile:

    gem 'lionel_richie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lionel_richie

## Setup

First, you'll create a Google client app. Visit the [Google API console](https://code.google.com/apis/console). Create an app. Feel free to call it "Trello Export" or "Lionel Richie".

Click the tab "API Access", then "Create an OAuth 2.0 Client ID" to open up a modal. Set a client name, like "CLI" for command line interface and continue. Next the modal presents "Client ID Settings"; choose "Installed Application" for "Application type", and "Other" for "Installed application type". Now press "Create client ID".

From your newly created client settings, grab the client ID and client secret. Add them to your environment:

    $ export GOOGLE_CLIENT_ID=your-google-client-id
    $ export GOOGLE_CLIENT_SECRET=your-google-client-secret

Next, you'll need to authorize the lionel_richie CLI. Run the following:

    $ authorize_lionel

Follow the instructions, which will include entering info on the command line from webpages on Trello and Google. If successful, you'll be able to export the following environment variables needed to run the export.

    $ export TRELLO_KEY=your-trello-key
    $ export TRELLO_TOKEN=your-trello-token
    $ export GOOGLE_TOKEN=your-google-token
    $ export GOOGLE_REFRESH_TOKEN=your-google-refresh-token

Finally, you need to set the trello board and the google doc you want to export. You can get these from the respective URLs for those resources.

    $ export TRELLO_BOARD_ID=your-trello-board-id
    $ export GOOGLE_DOC_ID=your-google-doc-id

You should now be ready to run the export:

    $ lionel

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
