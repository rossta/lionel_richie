module Lionel
  class ProxyCard
    extend Forwardable

    attr_reader :card, :attributes

    def_delegators :card, :id, :url, :name, :due

    def initialize(card, attributes)
      @card = card
      @attributes = attributes
    end

    def link(name = card.name)
      %Q[=HYPERLINK("#{card.url}", "#{name.gsub(/"/, "")}")]
    end

    MAX_ACTIONS = 1000
    def actions(options = {})
      options[:limit] = options.fetch(:limit, MAX_ACTIONS)
      @actions ||= card.actions(options).map { |a| Lionel::ProxyAction.new(a) }
    end

    def action_date(&block)
      filtered = actions.select(&block)
      return "" if filtered.empty?
      action = filtered.sort { |a, b| a.date <=> b.date }.first
      format_date action.date
    end

    def date_moved_to(list_name)
      action = first_action { |a| a.moved_to?(list_name) }
      return "" unless action
      format_date(action.date)
    end

    def create_date(start_list_name)
      ready_action = first_action do |a|
        (a.create? && a.board_id == attributes[:current_board_id]) || a.moved_to?(start_list_name)
      end
      format_date(ready_action.date) if ready_action
    end

    def format_date(date, format = "%m/%d/%Y")
      date.strftime(format)
    end

    def first_action(&block)
      actions.select(&block).sort { |a, b| a.date <=> b.date }.first
    end

    def type
      labels.detect { |l| l =~ %r{bug|chore|task}i } || 'story'
    end

    def project
      labels.detect { |l| l !~ %r{bug|chore|task}i }
    end

    def labels
      @labels ||= card.labels.map(&:name).map(&:downcase)
    end

    def estimate
      match = card.name.match(/\[(?<estimate>\w+)\]/)
      return "" unless match
      match[:estimate]
    end

    def due_date
      format_date(due) if due
    end

  end
end
