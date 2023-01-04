require "concurrent-ruby"
require 'set'

module Shatter
  module Service
    class ServiceDefinition
      include Concurrent::Async
      class << self
        attr_reader :function_collection
      end
      def self.register_function(identifier, function)
        Shatter.logger.info "Registering function - #{identifier} for #{self}"
        @function_collection ||= {}
        @function_collection[identifier.to_s] = function
        define_method identifier do |params|
          function.new(params).call
        end
      end
    end
  end
end