require "pg"
require "shatter/service/function"
require "shatter/service/function_params"

module MyApp
  module Functions
    class HelloWorldFunction < Shatter::Service::Function
      Params = Shatter::Service::FunctionParams.generate(:name)

      def invoke
        params.to_h => name:, uuid:
        { result: "Hello #{name}", uuid:, error: nil, uuid: }
      end
    end
  end
end