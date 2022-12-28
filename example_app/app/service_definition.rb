# frozen_string_literal: true

class ServiceDefinition < Shatter::Service::ServiceDefinition
  register_function :hello_world, HelloWorldFunction
end
