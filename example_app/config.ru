# frozen_string_literal: true

require "bundler/setup"
require "shatter"

require_relative "./config/environment"

use Rack::CommonLogger
run Shatter::Web::Server
