# frozen_string_literal: true

require_relative './functions/hello_world_function'

module MyApp
  class ServiceDefinition < Shatter::Service::ServiceDefinition
    register_function :hello_world, MyApp::Functions::HelloWorldFunction
  end
end
