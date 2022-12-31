require 'drb/drb'
require 'zk'

#Server Side of the drb
module Shatter
  class Service
    include Concurrent::Async
    @@service_class = nil
    def self.service_class= service_class
      @@service_class = service_class
    end

    def self.response_for(uuid)
      {"result:": {}}
    end

    def self.method_missing(m, *args, &block)
      raise 'Invalid Service Method' unless @@service_class.instance_methods.include?(m.to_sym)

      uuid = args[0] # first arg should ALWAYS be uuid
      my_ip = ENV['HOST_NAME'] || "druby://localhost:8787"
      ZK.open(Config.zookeeper_host) do |zk|
        key = Util.zookeeper_response_key(uuid)
        zk.create(key, my_ip)
      end
      @@service_class.new.send(m, *args, &block)
    end

    def self.init(service_class)
      @@service_class = Shatter::Examples::Service
      puts "Starting DRb service"
      uri = "druby://localhost:8787"
      DRb.start_service(uri, self)
      DRb.thread.join
    end
  end
end