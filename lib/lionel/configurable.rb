module Lionel
  module Configurable
    def self.included(base)
      base.extend ClassMethods
    end

    def configuration
      Configuration.instance
    end

    def save
      configuration.save(data)
    end

    def data
      {}
    end

  end

  module ClassMethods

    def config_accessor(*args)
      attr_writer(*args)

      args.each do |reader|
        define_method(reader) do
          instance_variable_get("@#{reader}") || configuration.send(reader)
        end
      end
    end
  end
end
