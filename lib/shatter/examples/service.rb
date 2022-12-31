# frozen_string_literal: true
require "concurrent-ruby"
require_relative './query_line_item_function'

module Shatter
  module Examples
    class Service
      include Concurrent::Async

      def self.register_function(identifier, function)
        define_method identifier do |params|
          function.new(params).call
        end
      end

      register_function :query_line_items, Shatter::Examples::QueryLineItemFunction
    end
  end
end
