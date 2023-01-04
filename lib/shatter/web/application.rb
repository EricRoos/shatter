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
        return unless druby_instance_url
        DRbObject.new_with_uri("druby://#{druby_instance_url}").response_for(uuid)
      end

      def route(uuid, path, params)
        operation = path.scan(/\/(.+)$/).first&.first
        raise 'failed to route' if operation.nil?
        Shatter.logger.info Shatter::Service::Base.service_definition.function_collection
        Shatter.logger.info operation
        function = Shatter::Service::Base.service_definition.function_collection[operation]
        if function.nil?
          DRbObject.new_with_uri("druby://#{Shatter::Service::Discovery.service_instance_url}")
            .set_static_result_for(uuid, {result: nil, error: :unknown_operation})
        else
          begin
            func_params = Object.const_get("#{function.to_s}::Params").new(**params.merge(uuid:))
            Shatter.logger.info "routing #{path}/#{func_params}"
            DRbObject.new_with_uri("druby://#{Shatter::Service::Discovery.service_instance_url}")
              .send(
                operation.to_sym,
                func_params
              )
          rescue ArgumentError => e
            DRbObject.new_with_uri("druby://#{Shatter::Service::Discovery.service_instance_url}")
              .set_static_result_for(uuid, {result: nil, error: e.message })
          end
        end
      rescue Exception => e
        Shatter.logger.error "caught error: #{e.message}"
        Shatter.logger.error "#{e.backtrace.join("\n")}"
        { data:, error: e.message, uuid: }
      end

    end
  end
end