module Shatter
  class Config
    @@zookeeper_host = nil
    def self.zookeeper_host= zookeeper_host
      @@zookeeper_host = zookeeper_host
    end
  end
end