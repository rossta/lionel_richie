module Lionel
  class ProxyAction
    attr_reader :action
    delegate :data, :type, :date, to: :action

    def initialize(action)
      @action = action
    end

    def data_attributes(key)
      data[key] || {}
    end

    def create?
      type == "createCard"
    end

    def update?
      type == "updateCard"
    end

    def board_id
      data_attributes("board")["id"]
    end

    def list_after
      data_attributes("listAfter")
    end

    def list_before
      data_attributes("listBefore")
    end

    def list_after?
      list_after.any?
    end

    def list_before?
      list_before.any?
    end

    def moved_to?(list_name)
      return false unless list_after?
      !!(list_after["name"] =~ %r{^#{Regexp.escape(list_name.downcase)}}i)
    end

  end
end
