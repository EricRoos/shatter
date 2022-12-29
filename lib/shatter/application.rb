module Shatter
  class Application
    include Concurrent::Async
    def missing_operation(uuid)
      {data: nil, error: :missing_operation}
    end
  end
end