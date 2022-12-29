require 'securerandom'
require 'json'
require 'concurrent-ruby'
require 'pg'

class App
  include Concurrent::Async
  def route(uuid, path, query_string)
    if(path == '/line_items')
      query_line_items(uuid)
    else
      missing_operation(uuid)
    end
  end

  def query_line_items(uuid)
    conn = PG.connect( "postgresql://postgres:mysecretpassword@localhost/microcal_development")
    res = conn.async_exec("SELECT * from line_items")
    {data: res.to_a, uuid:, error: nil}
  end

  def missing_operation(uuid)
    {data: nil, uuid:, error: :missing_operation}
  end
end

class ResponsePool
  include Singleton
  def initialize
    @response_pool = {}
  end

  def add_to_pool(uuid=nil, path, query_string)
    uuid ||= SecureRandom.uuid
    @response_pool[uuid] = nil
    future = App.new.async.route(uuid, path, query_string)
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
      path = env['PATH_INFO']
      query_string = env['QUERY_STRING']
      if env['PATH_INFO'] == '/callbacks'
        uuid = query_string.split("=")[1]
        response = ResponsePool.instance.pool(uuid)
        unless response.nil?
          return JSON.parse(response)
        end
        [200, {"delay" => "50", "location" => "/callbacks?uuid=#{uuid}"}, []]
      else
        uuid = SecureRandom.uuid
        ResponsePool.instance.add_to_pool(uuid, path, query_string)
        [200, {"delay" => "15", "location" => "/callbacks?uuid=#{uuid}"}, []]
      end
    end
  end
end
