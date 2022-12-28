# frozen_string_literal: true

require "bundler/setup"
require "shatter"
require "rack/cors"

require_relative "./config/environment"

use Rack::CommonLogger

use Rack::Cors do
  allow do
    origins "*"
    resource "*", headers: :any, methods: %i[get post patch put], expose: %w[delay location]
  end
end
run Shatter::Web::Server
