require "bundler/setup"
require "shatter"
require_relative './lib/shatter/example_app'

use Rack::CommonLogger
Shatter::ResponsePool.app_class = Shatter::ExampleApp
run Shatter::Server
