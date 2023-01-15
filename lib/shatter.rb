# frozen_string_literal: true

require "zeitwerk"
require_relative "./shatter/config"
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
    loader
  end

  def self.load_environment
    require "#{Shatter.root}/config/environment"
  end

  def self.load
    loader = Zeitwerk::Loader.for_gem
    Config.autoload_paths.each do |path|
      loader.push_dir(File.expand_path(path, Config.root))
    end
    loader.enable_reloading
    loader.setup # ready!
  end
  # Your code goes here...
end
