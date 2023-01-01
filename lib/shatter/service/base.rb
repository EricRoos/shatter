# frozen_string_literal: true
require 'singleton'
require 'benchmark'
require "drb/drb"
require "zk"
require "concurrent-ruby"

# Server Side of the drb
module Shatter
  module Service
    class Base
      include Concurrent::Async

      class ZooKeeperConnection
        include Singleton
        attr_reader :client
        def initialize
          @client = ZK.new(Shatter::Config.zookeeper_host)
        end
      end

      class << self
        attr_reader :service_definition
        attr_writer :service_definition
      end

      def self.response_for(uuid)
        ResponsePool.instance.pool[uuid]
      end

      def self.respond_to_missing?(method)
        @service_definition.instance_methods.include?(method.to_sym)
      end

      def self.method_missing(method, *args, &)
        puts "Running #{method} with args #{args}"
        uuid = args[0].uuid
        return {error: 'missing uuid'} if uuid.nil?
        my_ip = ENV["HOST_NAME"] || "localhost"
        host = "#{my_ip}:#{ENV['SHATTER_SERVICE_PORT']}"
        future = @service_definition.new.async.send(method, *args, &)
        future.add_observer(self, :populate_pool_with_result)
        zk = ZooKeeperConnection.instance.client
        key = nil
        key = Util.zookeeper_response_key(uuid)
        zk.create(key, host)
        my_ip
      end

      def self.populate_pool_with_result(time, value, err)
        if err
          puts err
        end
        ResponsePool.instance.pool[value[:uuid]] = value[:result]
      end

      def self.init
        puts "Initing DRb service"
        uri = "localhost:#{ENV["SHATTER_SERVICE_PORT"]}"
        puts "Logging my existnce at #{uri} to zookeeper"
        zk = ZooKeeperConnection.instance.client
        unless zk.exists?("/shater_service_instances/#{uri}")
          zk.create("/shater_service_instances/#{uri}")
        end
        puts "Starting DRb service"
        DRb.start_service("druby://#{uri}", self)
        DRb.thread.join
      end
    end
  end
end