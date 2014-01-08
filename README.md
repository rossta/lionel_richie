# LionelRichie

LionelRichie is a script for exporting Trello data to Google Docs.

This gem is in its very early stages so its probably not useful to you yet.

![lionel](https://www.evernote.com/shard/s111/sh/86ca745b-4e7e-4b06-9fd2-32112436c72b/19b422ac7bab8162f9268be34be85b2d/res/03b54478-c928-4732-8d6a-4b56bcc205dc/lionel-richie-trello.jpg?resizeSmall&width=832)

## Installation

Add this line to your application's Gemfile:

    gem 'lionel_richie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lionel_richie

## Setup

Assuming you have a Google account, a Trello account, and a board you want to export to google docs, you're ready to start using lionel_richie.

You'll first need to authorize your CLI to use the Trello and Google APIs.

To authorize, sign in to Trello and run the following command:

    $ lionel authorize trello

This command will direct you to a URL which has your trello key. Enter this into the CLI. You'll then be directed to a URL where you'll authorize the application to get your trello token. If you entered the key and token correctly, you should now be authorized to use Trello.

To authorize Google, run the following command:

    $ lionel authorize google

This command will direct you to the [Google API console](https://code.google.com/apis/console). You'll need to create a Google client app for LionelRichie. Feel free to call it whatever you want. Once you have registered a client app, click the tab "API Access", then "Create an OAuth 2.0 Client ID" to open up a modal. Set a client name, like "CLI" for command line interface and continue. Next the modal presents "Client ID Settings"; choose "Installed Application" for "Application type", and "Other" for "Installed application type". Now press "Create client ID". From your newly created client settings, grab the client id and client secret. Enter them in the CLI.

You'll then be directed to authorize the application and retrieve your google token.

You should now be ready to run the export:

    $ lionel export           # uploads to your google doc
    $ lionel export --print   # prints the output without uploading

When running this command for the first time, you'll be asked to enter your trello board id and google doc id, which you can grab from the respective URLs of those resources.

Run `lionel` to see a list of the available commands and options.

## Crafting the Export

```ruby
LionelRichie.export do
  # Card Id
  B { id }

  # Card Link
  C { link }

  # Ready date
  D do |export|
    ready_action = first_action do |a|
      (a.create? && a.board_id == export.trello_board_id) || a.moved_to?("Ready")
    end
    format_date(ready_action.date) if ready_action
  end

  # In Progress date
  E { date_moved_to("In Progress") }

  # Code Review date
  F { date_moved_to("Code Review") }

  # Review date
  G { date_moved_to("Review") }

  # Deploy date
  H { date_moved_to("Deploy") }

  # Completed date
  I { date_moved_to("Completed") }

  # Type
  J { type }

  # Project
  K { project }

  # Estimate
  L { estimate }

  # Due Date
  M { due_date }
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
