# frozen_string_literal: true

require "zeitwerk"
require_relative "./shatter/config"
module Shatter
  class Error < StandardError; end

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
