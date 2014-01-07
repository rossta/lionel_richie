module Lionel
  class ExportBuilder

    def self.build(&block)
      new.configure(&block)
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
        columns[sym.to_s.upcase] = block_given? ? block : args.first
      else
        raise ColumnConfigurationError.new("Method '#{sym}' does not represent a valid Google Spreadsheet column name")
      end
    end

  end
end
