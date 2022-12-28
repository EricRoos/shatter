# frozen_string_literal: true

require "singleton"
module Shatter
  module Service
    class ResponsePool
      include Singleton
      attr_reader :pool

      def initialize
        @pool = {}
      end
    end
  end
end
