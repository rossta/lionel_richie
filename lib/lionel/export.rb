module Lionel
  class Export
    include Configurable

    attr_reader :options

    config_accessor :google_doc_id, :trello_board_id

    def self.builder=(builder)
      @builder = builder
    end

    def self.builder
      @builder || ExportBuilder.default
    end

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
        Lionel.logger.info "DRY RUN..."
        Lionel.logger.info "Results were not uploaded to Google Drive"
      else
        Lionel.logger.info "Uploading..."
        upload
        Lionel.logger.info "Done!"
      end
    end

    def download
      raise_missing_builder_error unless builder

      Lionel.logger.info "Exporting trello board '#{board.name}' (#{trello_board_id}) to " + "google doc '#{spreadsheet.title}' (#{google_doc_id})"

      card_map.each do |row, card|
        begin
          Timeout.timeout(5) do
            row_data = card_columns(card).map do |col, value|
              worksheet[col,row] = value
            end.join(" | ")
            Lionel.logger.info "row[#{row}]: " + row_data
          end
        rescue Timeout::Error, Trello::Error => e
          Lionel.logger.warn e.inspect
          Lionel.logger.warn card.inspect
        end
      end
    end

    def card_map
      @card_map ||= CardMap.new(cards, worksheet)
    end

    def upload
      worksheet.save
    end

    def rows
      worksheet.rows
    end

    def builder
      self.class.builder
    end

    def card_columns(card)
      card_column_rows[card.id] ||= {}.tap do |columns|
        builder.columns.each do |col_name, block|
          columns[col_name] = card.instance_exec(self, &block)
        end
      end
    end

    def card_column_rows
      @card_column_rows ||= {}
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

    def raise_missing_builder_error
      message = <<-ERROR.gsub(/^ {6}/, '')
        The export is not configured. Example:

        Lionel.export do
          A { id }
          B { name }
          C { url }
        end
      ERROR
      raise MissingBuilderError.new(message)
    end

    class CardMap
      include Enumerable

      attr_reader :cards, :worksheet

      def initialize(cards, worksheet)
        @cards, @worksheet = cards, worksheet
      end

      def each(&block)
        rows.each(&block)
      end

      def rows
        @rows ||= populate_rows
      end

      private

      def populate_rows
        {}.tap do |card_rows|

          start_row = 2 # Currently assumes a header column
          rows = worksheet.size

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
        end
      end
    end

  end
end
