# frozen_string_literal: true

module Shatter
  module Util
    def self.zookeeper_response_key(uuid)
      "/shatter::response_data_locations/#{uuid}"
    end
  end
end
