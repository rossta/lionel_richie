require 'yajl'
require 'trello'
require 'google_drive'
require 'launchy'
require 'thor'
require 'logger'
require 'forwardable'
require 'lionel/version'
require 'lionel/cli'
require 'lionel/configuration'
require 'lionel/configurable'
require 'lionel/export'
require 'lionel/export_builder'
require 'lionel/proxy_action'
require 'lionel/proxy_card'
require 'lionel/proxy_worksheet'
require 'lionel/trello_authentication'
require 'lionel/google_authentication'

module Lionel
  Error = Class.new(StandardError)
  ColumnConfigurationError = Class.new(Error)

  extend self
  attr_accessor :logger

  def logger=(logger)
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}][#{severity}]: #{msg}\n"
    end
    @logger = logger
  end

  def export(&block)
    Export.builder = ExportBuilder.build(&block)
  end

end

Lionel.logger = Logger.new(STDOUT)
