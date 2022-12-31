# frozen_string_literal: true

require "bundler/setup"
require "shatter"
Shatter::Config.zookeeper_host = "localhost:2181"
use Rack::CommonLogger
run Shatter::Server
