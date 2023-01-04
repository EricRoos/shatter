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

      def self.set_static_result_for(uuid, result)
        puts "Setting static content"
        populate_pool_with_result(Time.now, {uuid:, result:}, nil)
      end

      def self.method_missing(method, *args, &)
        Shatter.logger.info "Mapping #{method}"
        uuid = args[0].is_a?(Hash) ? args[0][:uuid] : args[0].uuid
        return {error: 'missing uuid'} if uuid.nil?
        future = @service_definition.new.async.send(method, *args, &)
        future.add_observer(self, :populate_pool_with_result)
      end

      def self.populate_pool_with_result(time, value, err)
        if err
          Shatter.logger.info err
        end
        ResponsePool.instance.pool[value[:uuid]] = value
        zk = ZooKeeperConnection.instance.client
        key = nil
        key = Util.zookeeper_response_key(value[:uuid])
        my_ip = ENV["HOST_NAME"] || "localhost"
        host = "#{my_ip}:#{Shatter::Config.service_port}"
        Shatter.logger.info "Recording location of #{value[:uuid]} at #{host} #{value}"
        zk.create(key, host)
        my_ip
      rescue Exception => e
        Shatter.logger.error e
        raise e
      end

      def self.close
        logger = Shatter.logger
        logger.info "Closing down DRb service"
        port = Shatter::Config.service_port
        uri = "localhost:#{port}"
        logger.info "Removing my existnce at #{port} to zookeeper"
        Shatter::Service::Discovery.deregister_service(uri)
        logger.info "Closed DRb service"
      end

      def self.init
        logger.info "Initing DRb service"
        port = Shatter::Config.service_port
        uri = "localhost:#{port}"
        logger.info "Logging my existnce at #{uri} to zookeeper"
        Shatter::Service::Discovery.register_service(uri)
        logger.info "Starting DRb service"
        DRb.start_service("druby://#{uri}", self)
        logger.info "DRb service started"
        DRb.thread.join
      end

      def self.logger
        Shatter.logger
      end
    end
  end
end