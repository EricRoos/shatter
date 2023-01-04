require "pg"
require "shatter/service/function"
require "shatter/service/function_params"

module MyApp
  module Functions
    class HelloWorldFunction < Shatter::Service::Function

      define_param :name, nullable: false, type: 'string'
      define_param :number, nullable: false, type: 'integer'


      def invoke
        params.to_h => name:, number:
        { result: "Hello #{name}, your number is #{number || 'unknown'}.", error: nil, }
      end
    end
  end
end