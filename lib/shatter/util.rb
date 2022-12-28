# frozen_string_literal: true

require "logger"
require "singleton"

module Shatter
  module Util
    class Logger < ::Logger
      include Singleton
      def initialize
        super($stdout, datetime_format: "%Y-%m-%d %H:%M:%S")
      end
    end

    def self.zookeeper_response_key(uuid)
      raise "Cant produce key without uuid" if uuid.nil?

      "/shatter::response_data_locations/#{uuid}"
    end
  end
end
