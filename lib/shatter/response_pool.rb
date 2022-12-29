module Shatter
  class ResponsePool
    include Singleton

    @@app_class= nil
    def self.app_class= app_class
      @@app_class = app_class
    end

    def initialize
      @response_pool = {}
    end

    def add_to_pool(uuid=nil, path, query_string)
      uuid ||= SecureRandom.uuid
      @response_pool[uuid] = nil
      future = @@app_class.new.async.route(uuid, path, query_string)
      future.add_observer(self, :accept_data_for_uuid)
      uuid
    end

    def accept_data_for_uuid(time, value, err)
      value => {uuid:, data:}
      resp = [200, {'content-type' => 'application/json'}, [value.to_json]]
      @response_pool[uuid] = resp.to_json
      @response_pool[uuid]
    rescue Exception => e
      puts "Something went wrong"
      puts e.message
      puts e.backtrace
      raise e
    end

    def pool(uuid)
      @response_pool[uuid]
    end
  end
end