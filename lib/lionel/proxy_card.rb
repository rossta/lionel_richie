module Lionel
  class ProxyCard
    extend Forwardable

    attr_reader :card

    def_delegators :card, :id, :url, :name, :due

    def initialize(card)
      @card = card
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

    def checklist_count(name)
      checklist = card.checklists.find { |chl| chl.name == name }
      return 0 unless checklist
      checklist.check_items.count
    end

  end
end
