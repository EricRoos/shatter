# frozen_string_literal: true

module Shatter
  module Util
    def self.zookeeper_response_key(uuid)
      raise 'Cant produce key without uuid' if uuid.nil?
      "/shatter::response_data_locations/#{uuid}"
    end
  end
end
