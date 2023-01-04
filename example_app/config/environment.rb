Shatter::Config.zookeeper_host = "localhost:2181"
Shatter::Config.initial_delay = 100
Shatter::Config.missing_result_delay = 100
Shatter::Config.service_port = ENV.fetch('SHATTER_SERVICE_PORT') { 8787 }

require_relative '../application'

Shatter::Service::Base.service_definition = MyApp::ServiceDefinition
Shatter::Web::Server.application = MyApp::Application
