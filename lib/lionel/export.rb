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
        case options.fetch('filter', 'open-lists')
        when 'open-cards'
          retrieve_open_cards
        when 'open-lists'
          retrieve_open_cards_in_open_lists
        end.map { |c| Lionel::ProxyCard.new(c) }
      end
    end

    def spreadsheet
      @spreadsheet ||= google_session.spreadsheet_by_key(google_doc_id)
    end

    def worksheet
      @worksheet ||= get_worksheet
    end

    def process
      download

      if options['print']
        rows.each { |row| Lionel.logger.info row.inspect }
      else
        upload
      end
    end

    def download
      Lionel.logger.info "Exporting trello board '#{board.name}' (#{trello_board_id}) to " + "google doc '#{spreadsheet.title}' (#{google_doc_id})"

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
        begin
          Timeout.timeout(5) {
            Lionel.logger.info "row[#{row}] = #{card.name}"

            sync_columns(card).each do |col, value|
              worksheet[col,row] = value
            end
          }
        rescue Timeout::Error, Trello::Error => e
          Lionel.logger.warn e.inspect
          Lionel.logger.warn card.inspect
        end
      end
    end

    def upload
      worksheet.save
    end

    def rows
      worksheet.rows
    end

    def sync_columns(card)
      {}.tap do |columns|
        columns["B"] = card.id

        # Card link
        columns["C"] = card.link(card.name.gsub(/^\[.*\]\s*/, ""))

        # Ready date
        ready_action = card.first_action do |a|
          (a.create? && a.board_id == trello_board_id) || a.moved_to?("Ready")
        end
        columns["D"] = card.format_date(ready_action.date) if ready_action

        # In Progress date
        columns["E"] = card.date_moved_to("In Progress")

        # Code Review date
        columns["F"] = card.date_moved_to("Code Review")

        # Review date
        columns["G"] = card.date_moved_to("Review")

        # Deploy date
        columns["H"] = card.date_moved_to("Deploy")

        # Completed date
        columns["I"] = card.date_moved_to("Completed")

        # Type
        columns["J"] = card.type

        # Project
        columns["K"] = card.project

        # Estimate
        columns["L"] = card.estimate

        # Due Date
        columns["M"] = card.due_date
      end
    end

    def authenticate
      return if @authenticated
      authenticate_trello
      authenticate_google
      @authenticated
    end

    def authenticate_trello
      trello_session.configure
      @board = Trello::Board.find(trello_board_id)
    end

    def authenticate_google
      google_session
      @worksheet = Lionel::ProxyWorksheet.new(spreadsheet.worksheets[0])
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

  end
end
