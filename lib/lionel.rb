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
  ColumnNameError = Class.new(Error)
  MissingBuilderError = Class.new(Error)

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

Lionel.export do
  B { id }

  # Card link
  C { link(card.name.gsub(/^\[.*\]\s*/, "")) }

  # Ready date
  D { create_date("Ready") }

  # In Progress date
  E { date_moved_to("In Progress") }

  # Code Review date
  F { date_moved_to("Code Review") }

  # Review date
  G { date_moved_to("Review") }

  # Deploy date
  H { date_moved_to("Deploy") }

  # Completed date
  I { date_moved_to("Completed") }

  # Type
  J { type }

  # Project
  K { project }

  # Estimate
  L { estimate }

  # Due Date
  M { due_date }
end
