# frozen_string_literal: true

require "securerandom"
require "json"

module Shatter
  module Web
    class Server
      def self.call(env)
        request = Rack::Request.new(env)
        path = env["PATH_INFO"]
        if env["PATH_INFO"] == "/callbacks"
          uuid = env['QUERY_STRING'].split("=")[1]
          response_for(uuid)
        elsif env["PATH_INFO"] == "/base_time"
          [200, {}, [""]]
        else
          params = JSON.parse(request.body.read, {symbolize_names: true})
          uuid = SecureRandom.uuid
          future = Shatter::Examples::Application.new.async.route(uuid, path, params)
          [200, { "delay" => "50", "location" => "/callbacks?uuid=#{uuid}" }, []]
        end
      end

      def self.server_call_result(time, value, error)
        return if error.nil?
        Shatter.logger.error "#{ error }"
      end

      def self.response_for(uuid)
        response = Shatter::Examples::Application.new.response_for(uuid)
        return [200, {}, [response.to_json]] unless response.nil?

        [200, { "delay" => "100", "location" => "/callbacks?uuid=#{uuid}" }, []]
      end
    end
  end
end