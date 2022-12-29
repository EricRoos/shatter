require "bundler/setup"
require "shatter"

use Rack::CommonLogger
run Shatter::Server
