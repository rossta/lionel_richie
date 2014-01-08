# LionelRichie

[![Code Climate](https://codeclimate.com/github/rossta/lionel_richie.png)](https://codeclimate.com/github/rossta/lionel_richie)

LionelRichie is a script for exporting Trello data to Google Docs.

This gem is in its very early stages so its probably not useful to you yet.

![Trello? Is it me you're looking for?](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmSbZ56riC_raK-rR4HiV4YKjvXTTUQy4_GCpPAYqdSkCz3RhO)

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

    $ lionel export                         # uploads to your google doc
    $ lionel export --print                 # prints the output without uploading
    $ lionel export -c ./path/to/Lionelfile # uploads export configured by given Lionelfile

When running this command for the first time, you'll be asked to enter your trello board id and google doc id, which you can grab from the respective URLs of those resources.

Run `lionel` to see a list of the available commands and options.

## Crafting the Export

The export can be configured using the export DSL. Export methods take the form of a Google doc column, e.g. 'A', 'BC', etc. To set the value on a column, pass a value or a block. The block is rendered in the context of each `Card` object populated with data from Trello.

```ruby
# Lionelfile
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
