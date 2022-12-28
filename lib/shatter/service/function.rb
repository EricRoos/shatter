# frozen_string_literal: true

module Shatter
  module Service
    class Function
      def self.define_param(name, type:, nullable: true)
        @param_meta ||= {}
        @param_meta[name] = { name:, type:, nullable: }
      end

      def self.meta
        @param_meta || {}
      end
      define_param :uuid, nullable: false, type: "string"

      attr_reader :params

      def initialize(function_params)
        @params = function_params
      end

      def call
        { result: nil, error: "Invalid Parameters" } unless valid_params?
        { result: nil, error: nil }.merge(invoke.merge(uuid: params[:uuid]))
      rescue StandardError => e
        Shatter.logger.error e.message
        Shatter.logger.error e.backtrace
        { result: nil, error: "Something Went Wrong", uuid: params[:uuid] }
      end

      def valid_params?
        self.class.meta.each_key do |arg|
          return false unless valid_param?(arg)
        end
        true
      end

      def valid_param?(arg)
        meta = self.class.meta[arg]
        return false if meta.nil?

        meta => type:, nullable:
        val = value_for_arg(arg)
        return nullable if val.nil?

        return false if type == "string" && !val.is_a?(String)
        return false if type == "integer" && !val.is_a?(Integer)

        true
      end

      def value_for_arg(arg)
        @params[arg.to_s] || @params[arg.to_sym]
      end

      def self.invoke
        raise "cant invoke for base function"
      end
    end
  end
end
