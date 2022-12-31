require 'singleton'
require_relative './application'

module Shatter
  class ResponsePool
    include Singleton

    @@app_class= nil
    def self.app_class= app_class
      @@app_class = app_class
    end

    def initialize
      @response_pool = {}
    end

    def add_to_pool(uuid=nil, path, query_string)
      uuid ||= SecureRandom.uuid
      @response_pool[uuid] = nil
      uuid
    end

    def pool(uuid)
      @response_pool[uuid]
    end
  end
end