require "pg"
require "shatter/service/function"
require "shatter/service/function_params"

module Shatter
  module Examples
    class ShowLineItemFunction < Shatter::Service::Function
      Params = Shatter::Service::FunctionParams.generate(:line_item_id)

      def call
        uuid = params.uuid
        conn = PG.connect("postgresql://postgres:mysecretpassword@localhost/microcal_development")
        sql = "SELECT * from line_items WHERE id=$1"
        sql_params = [params.line_item_id]
        puts "[#{Time.now}][#{uuid}] #{sql} #{sql_params}"
        { result: conn.async_exec(sql, sql_params).to_a, uuid: }
      end
    end
  end
end