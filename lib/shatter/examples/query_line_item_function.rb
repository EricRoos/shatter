require "pg"
require "shatter/service/function"
require "shatter/service/function_params"

module Shatter
  module Examples
    class QueryLineItemFunction < Shatter::Service::Function
      Params = Shatter::Service::FunctionParams.generate

      def call
        uuid = params.uuid
        #conn = PG.connect("postgresql://postgres:mysecretpassword@localhost/microcal_development")
        #sql = "SELECT * from line_items"
        #Shatter.logger.info("#{sql}")
        #{ result: conn.async_exec(sql).to_a, uuid: }
        { result: [], uuid: }
      end
    end
  end
end