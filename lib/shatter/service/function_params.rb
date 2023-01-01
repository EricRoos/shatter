module Shatter
  module Service
    class FunctionParams
      def self.generate(*args)
        args << :uuid
        Data.define(*args)
      end
    end
  end
end