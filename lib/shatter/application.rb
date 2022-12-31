# frozen_string_literal: true

require "drb/drb"
require "concurrent-ruby"

require_relative "./application"

module Shatter
  class Application
    include Concurrent::Async

    def initialize
      DRb.start_service
      # client side of drb
    end

    def response_for(uuid)
      # instance that holds the data we need
      druby_instance_url = instance_url_for(uuid)
      data = nil
      if druby_instance_url
        app_server_client = DRbObject.new_with_uri(druby_instance_url)
        data = app_server_client.response_for(uuid)
      end
      { data:, error: nil, uuid: }
    end

    def route(uuid, path, _query_string)
      # load balancer druby url
      druby_ingress_url = nil
      ZK.open(Shatter::Config.zookeeper_host) do |zk|
        druby_ingress_url = zk.children("/shater_service_instances").sample
      end
      app_server_client = DRbObject.new_with_uri("druby://#{druby_ingress_url}")
      if path == "/line_items"
        data = app_server_client.query_line_items(uuid)
        { data:, error: nil, uuid: }
      else
        { data: nil, error: :missing_operation, uuid: }
      end
    end

    private

    def instance_url_for(uuid)
      druby_instance_url = nil
      ZK.open(Shatter::Config.zookeeper_host) do |zk|
        key = Util.zookeeper_response_key(uuid)
        druby_instance_url = zk.get(key)[0] if zk.exists?(key)
      end
      druby_instance_url
    end
  end
end
