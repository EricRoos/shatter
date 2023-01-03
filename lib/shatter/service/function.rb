module Shatter
  module Service
    class Function
      attr_reader :params
      def self.before_invoke(method)
        @before_invoke_list ||= []
      end

      def self.after_invoke(method)
        @after_invoke_list ||= []
      end

      def initialize(function_params)
        @params = function_params
      end

      def call
        
        self.invoke
      end

      def self.invoke
        raise 'cant invoke for base function'
      end
    end
  end
end