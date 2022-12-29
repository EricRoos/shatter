require_relative './application'

module Shatter
  class ExampleApp < Application
    def route(uuid, path, query_string)
      puts "Routing path #{path}"
      if(path == '/line_items')
        query_line_items.merge(uuid:)
      elsif(path == '/users')
        query_users(uuid).merge(uuid:)
      else
        missing_operation.merge(uuid:)
      end
    end

    def query_line_items(uuid)
      conn = PG.connect( "postgresql://postgres:mysecretpassword@localhost/microcal_development")
      res = conn.async_exec("SELECT * from line_items")
      {data: res.to_a, uuid:, error: nil}
    end

    def query_users(uuid)
      conn = PG.connect( "postgresql://postgres:mysecretpassword@localhost/microcal_development")
      res = conn.async_exec("SELECT * from users")
      {data: res.to_a, uuid:, error: nil}
    end
  end
end