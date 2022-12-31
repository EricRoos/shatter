# frozen_string_literal: true

require "drb/drb"
require "zk"

# Server Side of the drb
module Shatter
  class Service
    include Concurrent::Async
    class << self
      attr_reader :service_class
    end

    class << self
      attr_writer :service_class
    end

    def self.response_for(_uuid)
      { "result:": {} }
    end

    def self.respond_to_missing?(method)
      @service_class.instance_methods.include?(method.to_sym)
    end

    def self.method_missing(method, *args, &)
      uuid = args[0] # first arg should ALWAYS be uuid
      my_ip = ENV["HOST_NAME"] || "druby://localhost:8787"
      ZK.open(Config.zookeeper_host) do |zk|
        key = Util.zookeeper_response_key(uuid)
        zk.create(key, my_ip)
      end
      @service_class.new.send(method, *args, &)
    end

    def self.init
      @service_class = Shatter::Examples::Service
      puts "Starting DRb service"
      uri = "druby://localhost:8787"
      DRb.start_service(uri, self)
      DRb.thread.join
    end
  end
end
