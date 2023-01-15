# frozen_string_literal: true

require "drb/drb"
require "concurrent-ruby"

# Server Side of the drb
module Shatter
  module Service
    class Base
      class ReloadWrapper
        def self.method_missing(method, *args, &)
          Shatter::RELOAD_RW_LOCK.with_write_lock do
            Shatter.reload
          end
          Shatter::RELOAD_RW_LOCK.with_read_lock do
            Shatter::Service::Base.send(method, *args)
          end
        end
      end

      include Concurrent::Async

      class << self
        attr_accessor :service_definition
      end

      def self.response_for(uuid)
        Shatter::Service::ResponsePool.instance.pool[uuid]
      end

      def self.respond_to_missing?(method)
        @service_definition.new.respond_to?(method)
      end

      def self.set_static_result_for(uuid, result)
        populate_pool_with_result(Time.now, { uuid:, result: }, nil)
      end

      def self.method_missing(method, *args, &)
        super unless respond_to_missing?(method)
        uuid = args[0].is_a?(Hash) ? args[0][:uuid] : args[0].uuid
        return { error: "missing uuid" } if uuid.nil?

        future = @service_definition.new.async.send(method, *args, &)
        future.add_observer(self, :populate_pool_with_result)
      end

      def self.populate_pool_with_result(_time, value, err)
        Shatter.logger.info err if err
        Shatter.logger.info "#{value[:uuid]} => #{value}" unless err
        Shatter::Service::ResponsePool.instance.pool[value[:uuid]] = value
        Shatter::Service::Discovery.populate_result_location(value[:uuid])
      rescue StandardError => e
        Shatter.logger.error e
        raise e
      end

      def self.close
        logger = Shatter.logger
        logger.info "Closing down DRb service: #{@service_instance}"
        @service_instance.stop_service
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
        @service_instance = DRb.start_service("druby://#{uri}", Shatter::Config.reload_classes ? ReloadWrapper : self)
        logger.info "DRb service started"
        DRb.thread.join
      end

      def self.logger
        Shatter.logger
      end
    end
  end
end
