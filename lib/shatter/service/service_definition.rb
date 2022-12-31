require "concurrent-ruby"

module Shatter
  module Service
    class ServiceDefinition
      include Concurrent::Async

      def self.register_function(identifier, function)
        define_method identifier do |params|
          function.new(params).call
        end
      end
    end
  end
end