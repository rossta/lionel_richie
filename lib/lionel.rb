require 'yajl'
require 'trello'
require 'google_drive'
require 'launchy'
require 'thor'
require 'logger'
require 'lionel/version'
require 'lionel/cli'
require 'lionel/configuration'
require 'lionel/configurable'
require 'lionel/export'
require 'lionel/proxy_action'
require 'lionel/proxy_card'
require 'lionel/proxy_worksheet'
require 'lionel/trello_authentication'
require 'lionel/google_authentication'

module Lionel
  extend self
  attr_accessor :logger

  def logger=(logger)
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}][#{severity}]: #{msg}\n"
    end
    @logger = logger
  end
end

Lionel.logger = Logger.new(STDOUT)
