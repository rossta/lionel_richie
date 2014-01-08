module Lionel
  class ExportBuilder

    def self.build(&block)
      new.configure(&block)
    end

    def self.default
      build do
        A { id }
        B { name }
        C { url }
      end
    end

    def configure(&block)
      instance_eval(&block)
      self
    end

    def columns
      @columns ||= {}
    end

    def method_missing(sym, *args, &block)
      column_name = sym.to_s.upcase
      if column_name =~ /\A[A-Z]+\z/
        columns[sym.to_s.upcase] = block_given? ? block : lambda { args.first }
      else
        raise ColumnNameError.new("Method '#{sym}' does not represent a valid Google Spreadsheet column name")
      end
    end

  end
end
