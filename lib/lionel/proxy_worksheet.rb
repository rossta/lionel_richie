module Lionel
  class ProxyWorksheet
    delegate :rows, :save, to: :worksheet
    delegate :size, to: :rows

    attr_reader :worksheet
    def initialize(worksheet)
      @worksheet = worksheet
    end

    def []=(col, row, value)
      worksheet["#{col}#{row}"] = value
    end

    def [](col, row)
      worksheet["#{col}#{row}"]
    end

    HEADER_ROW = 1
    def content_rows
      rows(HEADER_ROW)
    end

  end
end
