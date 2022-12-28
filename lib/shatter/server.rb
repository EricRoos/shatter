require 'securerandom'
require 'json'
class App
  def operation_a
    sleep 0.03
  end
end
class StreamPool
  include Singleton
  def initialize
    @stream_pool = {}
    @time_map = {}
  end

  def add_to_pool(stream, uuid=nil, delayed_access_time=0)
    uuid ||= SecureRandom.uuid
    Thread.new do
      App.new.operation_a
      @stream_pool[uuid].reopen({uuid:}.to_json)
      @stream_pool[uuid].close_write
    end
    @stream_pool[uuid] = stream
    uuid
  end

  def write_to_stream(content, uuid)
    @stream_pool[uuid].write(content)
  end

  def close_stream(uuid)
    @stream_pool[uuid].close
    @stream_pool.delete(uuid)
  end

  def close_stream_async(uuid)
    Thread.new do
      if @stream_pool[uuid].closed?
        @stream_pool.delete(uuid)
      else
        close_stream_async(uuid)
      end
    end 
  end

  def pool(uuid)
    @stream_pool[uuid]
  end
end

module Shatter
  class Server
    def self.call(env)
      if env['PATH_INFO'] == '/callbacks'
        query = env['QUERY_STRING']
        uuid = query.split("=")[1]
        if StreamPool.instance.pool(uuid).closed_write?
          stream = StreamPool.instance.pool(uuid)
          StreamPool.instance.close_stream_async(uuid)
          [200, {'content-type' => 'application/json'}, stream]
        else
          [200, {"delay" => "100", "location" => "/callbacks?uuid=#{uuid}"}, []]
        end
      else
        uuid = SecureRandom.uuid
        Thread.new do
          StreamPool.instance.add_to_pool(StringIO.new, uuid)
        end
        [200, {"delay" => "100", "location" => "/callbacks?uuid=#{uuid}"}, []]
      end
    end
  end
end
