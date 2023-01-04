module Shatter
  module Service
    class FunctionParams < Data

      def self.generate(*args, &block)
        args << :uuid

        Data.define(*args) do
          def to_typescript
            typescript_name = self.class.to_s.split("::").last(2).join
            out = <<-HEREDOC.gsub(/^\s+/, "")
              type #{typescript_name} {
              };
              export default #{typescript_name}
            HEREDOC
          end
        end
      end
    end
  end
end