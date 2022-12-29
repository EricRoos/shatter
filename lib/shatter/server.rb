require 'securerandom'
require 'json'
require 'concurrent-ruby'
require 'pg'

require_relative './example_app'
require_relative './response_pool'

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
