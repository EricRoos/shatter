require 'pg'
require 'drb/drb'

# The URI for the server to connect to
URI="druby://localhost:8787"

#Server Side of the drb
module Shatter
  class Service
    def self.init(service_class)
      DRb.start_service(URI, service_class)
      DRb.thread.join
    end
  end
end