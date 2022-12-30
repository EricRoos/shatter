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
        data = @app_server.query_line_items(uuid)
        {data:, error: nil, uuid: }
      else
        {data: nil, error: :missing_operation, uuid: }
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    end

  end
end