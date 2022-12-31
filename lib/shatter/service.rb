# frozen_string_literal: true



require 'benchmark'
require "drb/drb"
require "zk"
require "concurrent-ruby"

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
      puts "[#{Time.now}][#{self}][#{uuid}] - #{method}"
      future = @service_class.new.async.send(method, *args, &)
      my_ip
    end

    def self.init
      @service_class = Shatter::Examples::Service
      puts "Initing DRb service"
      uri = "localhost:#{ENV["SHATTER_SERVICE_PORT"]}"
      ZK.open(Config.zookeeper_host) do |zk|
        unless zk.exists?("/shater_service_instances/#{uri}")
          zk.create("/shater_service_instances/#{uri}")
        end
      end
      puts "Starting DRb service"
      DRb.start_service("druby://#{uri}", self)
      DRb.thread.join
    end
  end
end
