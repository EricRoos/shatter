require 'pg'

# example client side of the drb
module Shatter
  class ExampleService
    def query_line_items
      conn = PG.connect( "postgresql://postgres:mysecretpassword@localhost/microcal_development")
      conn.async_exec("SELECT * from line_items").to_a
    end
  end
end