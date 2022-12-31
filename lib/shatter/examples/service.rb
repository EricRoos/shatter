# frozen_string_literal: true

require "pg"
require "concurrent-ruby"
module Shatter
  module Examples
    class Service
      include Concurrent::Async
      # TODO: Add Method Allow List for Security

      def query_line_items(uuid)
        conn = PG.connect("postgresql://postgres:mysecretpassword@localhost/microcal_development")
        sql = "SELECT * from line_items"
        puts "[#{Time.now}][#{self.class}][#{uuid}]#{sql}"
        { result: conn.async_exec(sql).to_a, uuid: }
      end
    end
  end
end
