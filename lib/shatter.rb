# frozen_string_literal: true

require_relative "shatter/version"
require_relative "shatter/web/application"
require_relative "shatter/config"
require_relative "shatter/web/server"
require_relative "shatter/service/base"
require_relative "shatter/service/service_definition"
require_relative "shatter/service/response_pool"
require_relative "shatter/util"
require_relative "shatter/examples/service_definition"
require_relative "shatter/examples/application"

$stdout.sync = true

module Shatter
  class Error < StandardError; end
  # Your code goes here...
end
