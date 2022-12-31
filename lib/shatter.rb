# frozen_string_literal: true

require_relative "shatter/version"
require_relative "shatter/application"
require_relative "shatter/config"
require_relative "shatter/server"
require_relative "shatter/service"
require_relative "shatter/response_pool"
require_relative "shatter/util"
require_relative "shatter/examples/service"

$stdout.sync = true

module Shatter
  class Error < StandardError; end
  # Your code goes here...
end
