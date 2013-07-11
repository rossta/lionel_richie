require 'singleton'
require 'ostruct'

module Lionel
  class Configuration
    include Singleton
    attr_reader :path, :data

    FILE_NAME = '.lionelrc'
    CONFIG_ACCESSORS = [
      :trello_key, :trello_token, :trello_board_id,
      :google_token, :google_refresh_token,
      :google_client_id, :google_client_secret,
      :google_doc_id
    ]

    def self.config_accessor(*args)
      delegate(*args, to: :data)

      args.each do |accessor|
        define_method("#{accessor}=") do |value|
          data.send("#{accessor}=", value)
          write
        end
      end
    end

    config_accessor(*CONFIG_ACCESSORS)

    def initialize
      @path = File.join(File.expand_path("~"), FILE_NAME)
      @data = OpenStruct.new(load_data)
    end

    def save(attrs = {})
      attrs.each do |accessor, value|
        data.send("#{accessor}=", value)
      end
      write
    end

    def load_data
      load_file
    rescue Errno::ENOENT
      puts "Couldn't load file, falling back to ENV"
      default_data
    end

    def default_data
      # {
      #   'trello_key' => ENV['TRELLO_KEY'],
      #   'trello_token' => ENV['TRELLO_TOKEN'],
      #   'trello_board_id' => ENV['TRELLO_BOARD_ID'],
      #   'google_token' => ENV['GOOGLE_TOKEN'],
      #   'google_refresh_token' => ENV['GOOGLE_REFRESH_TOKEN'],
      #   'google_doc_id' => ENV['GOOGLE_DOC_ID']
      #   'google_client_id' => ENV['GOOGLE_CLIENT_ID']
      #   'google_client_secret' => ENV['GOOGLE_CLIENT_SECRET']
      # }
      {}.tap do |data|
        CONFIG_ACCESSORS.each do |name|
          data[name] = ENV[name.to_s.upcase]
        end
      end
    end

    def load_file
      require 'yaml'
      YAML.load_file(@path)
    end

    def write
      require 'yaml'
      File.open(@path, File::RDWR|File::TRUNC|File::CREAT, 0600) do |rcfile|
        rcfile.write @data.marshal_dump.to_yaml
      end
    end

  end
end
