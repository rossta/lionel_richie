module Lionel
  module Configurable
    def self.included(base)
      base.extend ClassMethods
    end

    def configuration
      Configuration.instance
    end

    def save_configuration
      configuration.save(data)
    end

    def data
      {}
    end

    def configured?
      self.class.config_accessors.all? { |accessor| !!send(accessor) }
    end
  end

  module ClassMethods

    def config_accessors
      @config_accessors ||= []
    end

    def config_accessor(*args)
      attr_writer(*args)

      args.each { |accessor| config_accessors << accessor }

      args.each do |reader|
        define_method(reader) do
          instance_variable_get("@#{reader}") || configuration.send(reader)
        end
      end
    end
  end
end
