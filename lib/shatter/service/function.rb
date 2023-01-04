module Shatter
  module Service
    class Function

      def self.define_param(name, type:, nullable: true)
        @@param_meta ||= {}
        @@param_meta[name] = {name:, type:, nullable:}
      end

      def self.meta
        @@param_meta
      end

      define_param :uuid, nullable: false, type: 'string'

      def initialize(function_params)
        @params = function_params
      end

      def params
        Hash[@@param_meta.keys.map { |k| [k]}].merge(@params)
      end

      def call
        raise 'Invalid Args' unless valid_params?
        valid_keys = @@param_meta.keys
        {result: nil, error:nil}.merge(self.invoke.merge(uuid: params[:uuid]))
      rescue Exception => e
        {result: nil, error: e.message, uuid: params[:uuid]}
      end

      def valid_params?
        self.class.meta.keys.each do |arg|
          meta = self.class.meta[arg]
          val = @params[arg]
          puts meta
          raise "#{arg} cannot be nil" if !meta[:nullable] && val.nil?
          raise "expected #{arg} to be a string" if meta[:type]  == 'string' && !val.is_a?(String)

          if meta[:type]  == 'integer'
            if !meta[:nullable] && val.nil?
              raise 'value cannot be nil'
            end
            if !val.nil? && !val.is_a?(Integer)
              raise "expected #{arg} to be an integer"
            end
          end
        end
      end

      def self.invoke
        raise 'cant invoke for base function'
      end
    end
  end
end