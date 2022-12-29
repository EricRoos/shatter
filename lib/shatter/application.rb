require 'drb/drb'
require 'concurrent-ruby'

require_relative './application'

module Shatter
  class Application
    include Concurrent::Async

    def initialize
      DRb.start_service
      @app_server = DRbObject.new_with_uri("druby://localhost:8787")
    end

    def route(uuid, path, query_string)
      if(path == '/line_items')
        query_line_items.merge(uuid:)
      else
        missing_operation.merge(uuid:)
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    end

    def query_line_items
      data = @app_server.query_line_items
      {data:, error: nil}
    end

    def missing_operation
      {data: nil, error: :missing_operation}
    end
  end
end