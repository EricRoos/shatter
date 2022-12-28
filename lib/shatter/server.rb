require 'securerandom'
require 'json'
require 'concurrent-ruby'
class App
  include Concurrent::Async

  def operation_a(uuid)
    {data: "data", uuid:}
  end
end

class ResponsePool
  include Singleton
  def initialize
    @response_pool = {}
  end

  def add_to_pool(uuid=nil)
    uuid ||= SecureRandom.uuid
    @response_pool[uuid] = nil
    future = App.new.async.operation_a(uuid)
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

module Shatter
  class Server
    def self.call(env)
      if env['PATH_INFO'] == '/callbacks'
        query = env['QUERY_STRING']
        uuid = query.split("=")[1]
        response = ResponsePool.instance.pool(uuid)
        unless response.nil?
          return JSON.parse(response)
        end
        [200, {"delay" => "50", "location" => "/callbacks?uuid=#{uuid}"}, []]
      else
        uuid = SecureRandom.uuid
        ResponsePool.instance.add_to_pool(uuid)
        [200, {"delay" => "15", "location" => "/callbacks?uuid=#{uuid}"}, []]
      end
    end
  end
end
