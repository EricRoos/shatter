module Shatter
  module Service
    class Function
      attr_reader :params
      def initialize(function_params)
        @params = function_params
      end

      def call
        raise 'Cannot call #call on base function'
      end
    end
  end
end