# frozen_string_literal: true

Shatter.config do |config|
  config.root = File.expand_path("..", __dir__)
  config.zookeeper_host = "localhost:2181"
  config.initial_delay = 100
  config.missing_result_delay = 100
  config.service_port = ENV.fetch("SHATTER_SERVICE_PORT", 8787)
  config.autoload_paths = %w[app app/functions]
end

Shatter.load

Shatter::Service::Base.service_definition = ServiceDefinition
Shatter::Web::Server.application = Application
