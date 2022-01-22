# frozen_string_literal: true

require_relative "water_wheel/version"
require_relative "water_wheel/backup"
require_relative "water_wheel/configuration"

module WaterWheel
  class << self
    attr_accessor :logger

    def logger # rubocop:disable Lint/DuplicateMethods
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
        log.level = Logger::INFO
      end
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
