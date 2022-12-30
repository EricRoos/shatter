require 'pg'
require 'drb/drb'

#Server Side of the drb
module Shatter
  class Service
    def self.init(service_class)
      puts "Starting DRb service"
      uri = "druby://localhost:8787"
      DRb.start_service(uri, service_class)
      DRb.thread.join
    end
  end
end