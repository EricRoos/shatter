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
        @function_collection ||= Set.new
        @function_collection.add(identifier.to_s)
        define_method identifier do |params|
          function.new(params).call
        end
      end
    end
  end
end