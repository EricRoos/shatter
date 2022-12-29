require 'singleton'
require_relative './application'

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
      future = Application.new.async.route(uuid, path, query_string)
      future.add_observer(self, :accept_data_for_uuid)
      uuid
    end

    def accept_data_for_uuid(time, value, err)
      if err
        value = { data: nil, error: err}
        status = 500
      else
        value => {uuid:}
        status = 200
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      value = {data: nil, error: 'Something went wrong'}
      status = 500
    ensure 
      resp = [status, {'content-type' => 'application/json'}, [value.to_json]]
      @response_pool[uuid] = resp.to_json
      @response_pool[uuid]
    end

    def pool(uuid)
      @response_pool[uuid]
    end
  end
end