require 'singleton'
module Shatter
  class ResponsePool
    include Singleton
    attr_reader :pool
    def initialize
      @pool = {}
    end
  end
end