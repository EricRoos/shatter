# frozen_string_literal: true

require "securerandom"
require "json"

require_relative "./response_pool"

module Shatter
  class Server
    def self.call(env)
      path = env["PATH_INFO"]
      query_string = env["QUERY_STRING"]
      if env["PATH_INFO"] == "/callbacks"
        uuid = query_string.split("=")[1]
        response_for(uuid)
      else
        uuid = SecureRandom.uuid
        Application.new.async.route(uuid, path, query_string)
        [200, { "delay" => "100", "location" => "/callbacks?uuid=#{uuid}" }, []]
      end
    end

    def self.response_for(uuid)
      response = Application.new.response_for(uuid)
      return [200, {}, [response.to_json]] unless response.nil?

      [200, { "delay" => "2000", "location" => "/callbacks?uuid=#{uuid}" }, []]
    end
  end
end
