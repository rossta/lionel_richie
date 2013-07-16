module Lionel
  class Export
    include Configurable

    attr_reader :options

    config_accessor :google_doc_id, :trello_board_id

    def initialize(options = {})
      @options = options
    end

    def data
      {
        trello_board_id: trello_board_id,
        google_doc_id: google_doc_id
      }
    end

    def board
      @board ||= Trello::Board.find(trello_board_id)
    end

    def cards
      # iterate over active lists rather
      # than retrieving all historical cards;
      # trello api returns association proxy
      # that does not respond to "flatten"
      @cards ||= begin
        case options.fetch(:filter, :open_cards)
        when :open_cards
          retrieve_open_cards
        when :open_lists
          retrieve_open_cards_in_open_lists
        end.map { |c| Lionel::ProxyCard.new(c) }
      end
    end

    def spreadsheet
      @spreadsheet ||= google_session.spreadsheet_by_key(google_doc_id)
    end

    def worksheet
      @worksheet ||= Lionel::ProxyWorksheet.new(spreadsheet.worksheets[0])
    end

    def download
      puts "Exporting trello board '#{board.name}' (#{trello_board_id}) to " + "google doc '#{spreadsheet.title}' (#{google_doc_id})"

      start_row = 2
      rows = worksheet.size

      card_rows = {}

      # Find existing rows for current cards
      (start_row..rows).each do |row|
        cell_id = worksheet["B",row]
        next unless cell_id.present?
        card = cards.find { |c| c.id == cell_id }
        next unless card.present?
        card_rows[row] = card
      end

      # Set available rows for new cards
      new_cards = cards - card_rows.values
      new_cards.each_with_index do |card, i|
        row = rows + i + 1
        card_rows[row] = card
      end

      card_rows.each do |row, card|
        Timeout.timeout(5) { sync_row(row, card) }
      end
    end

    class CardMap
      include Enumerable

      attr_reader :cards, :worksheet

      def initialize(cards, worksheet)
        @cards, @worksheet = cards, worksheet
      end

      def each(&block)
        card_rows.each(&block)
      end

      def card_rows
        @card_rows ||= {}.tap do |map|
        end
      end
    end

    def upload
      worksheet.save
    end

    def rows
      worksheet.rows
    end

    def sync_row(row, card)
      puts "row[#{row}] : #{card.name}"

      worksheet["B",row] = card.id

      # Card link
      worksheet["C",row] = card.link

      # Ready date
      ready_action = card.first_action do |a|
        (a.create? && a.board_id == trello_board_id) || a.moved_to?("Ready")
      end
      worksheet["D",row] = card.format_date(ready_action.date) if ready_action

      # In Progress date
      worksheet["E",row] = card.date_moved_to("In Progress")

      # Code Review date
      worksheet["F",row] = card.date_moved_to("Code Review")

      # Review date
      worksheet["G",row] = card.date_moved_to("Review")

      # Deploy date
      worksheet["H",row] = card.date_moved_to("Deploy")

      # Completed date
      worksheet["I",row] = card.date_moved_to("Completed")

      # Type
      worksheet["J",row] = card.type

      # Project
      worksheet["K",row] = card.project

      # Estimate
      worksheet["L",row] = card.estimate

      # Due Date
      worksheet["M",row] = card.due_date

    rescue Trello::Error => e
      puts e.inspect
      puts card.inspect
    end

    def authenticate
      return if @authenticated
      trello_session.configure
      google_session
      @authenticated
    end

    def google_session
      @google_session ||= GoogleDrive.login_with_oauth(configuration.google_token)
    end

    def trello_session
      @trello_session ||= TrelloAuthentication.new
    end

    def retrieve_open_cards
      board.cards(filter: :open)
    end

    def retrieve_open_cards_in_open_lists
      [].tap do |c|
        board.lists(filter: :open).each do |list|
          list.cards(filter: :open).each do |card|
            c << card
          end
        end
      end
    end

  end
end
