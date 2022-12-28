# frozen_string_literal: true

require "drb/drb"
require "concurrent-ruby"

module Shatter
  module Web
    class Application
      include Concurrent::Async

      def response_for(uuid)
        client = service_client(Shatter::Service::Discovery.service_instance_url_for_uuid(uuid))
        return if client.nil?

        client.response_for(uuid)
      end

      def route(uuid, path, params)
        operation = operation_for(path)
        return unknown_operation(uuid) if operation.nil?

        client = service_client
        client.send(operation.to_sym, params.merge(uuid:))
      rescue StandardError => e
        error_response(uuid, e)
      end

      protected

      def unknown_operation(uuid)
        service_client.set_static_result_for(uuid, { result: nil, error: :unknown_operation })
      end

      def error_response(uuid, err)
        Shatter.logger.error err
        service_client.set_static_result_for(uuid, { result: nil, error: "Something went wrong" })
      end

      def service_client(druby_instance_url = Shatter::Service::Discovery.service_instance_url)
        return if druby_instance_url.nil?

        DRbObject.new_with_uri("druby://#{druby_instance_url}")
      end

      def operation_for(path)
        operation = path.scan(%r{/(.+)$}).first&.first
        function = Shatter::Service::Base.service_definition.function_collection[operation]
        function.nil? ? nil : operation
      end
    end
  end
end
