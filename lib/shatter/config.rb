# frozen_string_literal: true

module Shatter
  class Config
    class << self
      attr_accessor :zookeeper_host
      attr_accessor :initial_delay
      attr_accessor :missing_result_delay
      attr_accessor :service_port
    end
  end
end
