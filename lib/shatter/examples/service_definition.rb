# frozen_string_literal: true
require "concurrent-ruby"
require_relative './query_line_item_function'

module Shatter
  module Examples
    class ServiceDefinition < Shatter::Service::ServiceDefinition
      register_function :query_line_items, Shatter::Examples::QueryLineItemFunction
    end
  end
end
