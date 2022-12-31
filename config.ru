# frozen_string_literal: true

require "bundler/setup"
require "shatter"

Shatter::Config.zookeeper_host = "localhost:2181"
Shatter::Config.initial_delay = 100
Shatter::Config.missing_result_delay = 100

use Rack::CommonLogger
run Shatter::Web::Server
