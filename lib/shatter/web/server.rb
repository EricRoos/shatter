# frozen_string_literal: true

require "securerandom"
require "json"

module Shatter
  module Web
    class Server
      def self.call(env)
        path = env["PATH_INFO"]
        query_string = env["QUERY_STRING"]
        if env["PATH_INFO"] == "/callbacks"
          uuid = query_string.split("=")[1]
          response_for(uuid)
        else
          uuid = SecureRandom.uuid
          future = Shatter::Examples::Application.new.route(uuid, path, query_string)
          #future.add_observer(self, :server_call_result)
          [200, { "delay" => "100", "location" => "/callbacks?uuid=#{uuid}" }, []]
        end
      end

      def self.server_call_result(time, value, error)
        puts "[#{time}] #{ error.nil? ? value : error }"
      end

      def self.response_for(uuid)
        response = Shatter::Examples::Application.new.response_for(uuid)
        return [200, {}, [response.to_json]] unless response.nil?

        [200, { "delay" => "100", "location" => "/callbacks?uuid=#{uuid}" }, []]
      end
    end
  end
end