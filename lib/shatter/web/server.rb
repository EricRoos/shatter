# frozen_string_literal: true

require "securerandom"
require "json"

module Shatter
  module Web
    class Server
      class << self
        attr_accessor :application
      end

      def self.call(env)
        request = Rack::Request.new(env)
        if env["PATH_INFO"] == "/callbacks"
          uuid = env["QUERY_STRING"].split("=")[1]
          handle_response_for_request(uuid)
        elsif request.post?
          handle_operation_request(env)
        else
          [404, {}, []]
        end
      end

      def self.handle_operation_request(env)
        request = Rack::Request.new(env)
        params = begin
          JSON.parse(request.body.read, { symbolize_names: true })
        rescue StandardError
          {}
        end
        uuid = SecureRandom.uuid
        future = application.new.async.route(uuid, request.path, params)
        future.add_observer(:service_callback, self)
        [200, { "delay" => Shatter::Config.initial_delay, "location" => "/callbacks?uuid=#{uuid}" }, []]
      end

      def self.service_callback(_time, _value, error)
        return if error.nil?

        Shatter.logger.error error.to_s
      end

      def self.handle_response_for_request(uuid)
        response = application.new.response_for(uuid)
        return [200, {}, [response.to_json]] unless response.nil?

        [200, { "delay" => Shatter::Config.missing_result_delay, "location" => "/callbacks?uuid=#{uuid}" }, []]
      end
    end
  end
end
