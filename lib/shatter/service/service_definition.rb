# frozen_string_literal: true

require "concurrent-ruby"

module Shatter
  module Service
    class ServiceDefinition
      include Concurrent::Async
      class << self
        attr_accessor :function_collection
      end
      def self.register_function(identifier, function)
        @function_collection ||= {}
        @function_collection[identifier.to_s] = function
        define_method identifier do |params|
          function.new(params).call
        end
      end
    end
  end
end
