# frozen_string_literal: true

require "drb/drb"
require "concurrent-ruby"

require_relative "./application"

module Shatter
  module Web
    class Application
      include Concurrent::Async

      def response_for(uuid)
        druby_instance_url = Shatter::Service::Discovery.service_instance_url_for_uuid(uuid)
        data = DRbObject.new_with_uri("druby://#{druby_instance_url}").response_for(uuid) if druby_instance_url
        { data:, error: nil, uuid: }
      end

      def route(uuid, path, params)
        operation = path.scan(/\/(.+)$/).first&.first
        return nil if operation.nil?
        function = Shatter::Examples::ServiceDefinition.function_collection[operation]
        func_params = Object.const_get("#{function.to_s}::Params").new(**params.merge(uuid:))
        Shatter.logger.info "routing #{path}/#{func_params}"
        DRbObject.new_with_uri("druby://#{Shatter::Service::Discovery.service_instance_url}")
          .send(
            operation.to_sym,
            func_params
          )
      end

    end
  end
end