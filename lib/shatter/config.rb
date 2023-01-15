# frozen_string_literal: true

module Shatter
  class Config
    class << self
      attr_accessor :zookeeper_host, :service_port, :root, :reload_classes
      attr_writer :autoload_paths, :initial_delay, :missing_result_delay

      def autoload_paths
        @autoload_paths ||= []
      end

      def initial_delay
        @initial_delay || 100
      end

      def missing_result_delay
        @missing_result_delay || 100
      end
    end
  end
end
