require 'pg'
module Shatter
  module Examples
    class Service
      # TODO: Add Method Allow List for Security

      def query_line_items(uuid)
        puts "[#{Time.now}][#{uuid}] #query_line_items"
        conn = PG.connect( "postgresql://postgres:mysecretpassword@localhost/microcal_development")
        sql = "SELECT * from line_items"
        puts "[#{Time.now}][#{uuid}] #{sql}"
        conn.async_exec(sql).to_a
      end
    end
  end
end