# frozen_string_literal: true

require_relative "shatter/version"
require_relative "shatter/web/application"
require_relative "shatter/config"
require_relative "shatter/web/server"
require_relative "shatter/service/base"
require_relative "shatter/service/discovery"
require_relative "shatter/service/service_definition"
require_relative "shatter/service/response_pool"
require_relative "shatter/util"

$stdout.sync = true

module Shatter
  class Error < StandardError; end
  def self.logger
    Util::Logger.instance
  end
  # Your code goes here...
end
