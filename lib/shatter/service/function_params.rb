module Shatter
  module Service
    class FunctionParams
      attr_accessor :uuid
      def initialize(uuid:)
        @uuid = uuid
      end
    end
  end
end