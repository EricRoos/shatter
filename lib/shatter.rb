# frozen_string_literal: true

require "zeitwerk"
require "concurrent/atomic/read_write_lock"
Dir["#{__dir__}/shatter/service/*.rb"].each { |file| require file }
Dir["#{__dir__}/shatter/web/*.rb"].each { |file| require file }
Dir["#{__dir__}/shatter/ext/*.rb"].each { |file| require file }
require_relative "./shatter/config"
require_relative "./shatter/util"
require_relative "./shatter/version"

module Shatter
  class Error < StandardError; end

  def self.root
    current = Dir.pwd
    root_dir = nil

    while current.size >= 1 && root_dir.nil?
      root_dir = current if Dir.children(current).include?("Gemfile")
      current = File.expand_path("..", current) if root_dir.nil?
      Dir.new(current)
    end
    root_dir
  end

  def self.logger
    Util::Logger.instance
  end

  def self.config(&block)
    block.call(Config) and return if block_given?

    Config
  end

  def self.loader
    @loader
  end

  def self.load_environment
    require "#{Shatter.root}/config/environment.rb"
  end

  def self.reload
    @loader.reload
    link_definitions
  end

  def self.load
    # @loader = Zeitwerk::Loader.for_gem
    @loader = Zeitwerk::Loader.new
    @loader.tag = File.basename(__FILE__, ".rb")
    @loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
    Config.autoload_paths.each do |path|
      @loader.push_dir(File.expand_path(path, root))
    end
    @loader.enable_reloading
    @loader.setup # ready!
    link_definitions
  end

  def self.link_definitions
    Shatter::Service::Base.service_definition = ServiceDefinition if Object.const_defined?("ServiceDefinition")
    Shatter::Web::Server.application = Application if Object.const_defined?("Application")
  end
  # Your code goes here...
end
Shatter::RELOAD_RW_LOCK = Concurrent::ReadWriteLock.new
