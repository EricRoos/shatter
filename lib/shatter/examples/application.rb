module Shatter
  module Examples
    class Application < Shatter::Web::Application
      def route(uuid, path, _query_string)
        if path == "/line_items"
          data = app_server_client.query_line_items(Shatter::Examples::QueryLineItemFunction::Params.new(uuid:))
          { data:, error: nil, uuid: }
        end
        app_server_client.close
        { data: nil, error: :missing_operation, uuid: }
      end
    end
  end
end