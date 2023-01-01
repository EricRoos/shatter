# frozen_string_literal: true

require "drb/drb"
require "concurrent-ruby"

require_relative "./application"

module Shatter
  module Web
    class Application
      include Concurrent::Async

      def response_for(uuid)
        raise 'cant produce response without uuid' if uuid.nil?
        druby_instance_url = instance_url_for(uuid)
        data = nil
        if druby_instance_url
          app_server_client = DRbObject.new_with_uri(druby_instance_url)
          data = app_server_client.response_for(uuid)
        end
        { data:, error: nil, uuid: } if !data.nil?
      end

      def route(uuid, path, _query_string)
        puts "Routing #{path} for #{uuid}"
        operation = path.scan(/\/(.+)$/).first&.first
        puts "Sending #{operation} to the services"
        return nil if operation.nil?
        Shatter::Examples::ServiceDefinition.function_collection[operation]
        Object.const_get("#{Shatter::Examples::QueryLineItemFunction.to_s}::Params")
        app_server_client.send(operation.to_sym,Shatter::Examples::QueryLineItemFunction::Params.new(uuid:))
      end

      private

      def app_server_client
        return @app_server_client unless @app_server_client.nil?
        druby_ingress_url = nil
        zk = ZK.new (Shatter::Config.zookeeper_host)
        druby_ingress_url = zk.children("/shater_service_instances").sample
        raise 'couldnt find a server to reach for service' if druby_ingress_url.nil?
        zk.close
        @app_server_client = DRbObject.new_with_uri("druby://#{druby_ingress_url}")
      end

      def instance_url_for(uuid)
        druby_instance_url = nil
        zk = ZK.new(Shatter::Config.zookeeper_host)
        key = Util.zookeeper_response_key(uuid)
        druby_instance_url = zk.get(key)[0] if zk.exists?(key)
        zk.close
        return nil if druby_instance_url.nil?
        "druby://#{druby_instance_url}"
      end
    end
  end
end