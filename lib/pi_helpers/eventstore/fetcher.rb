# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './page'

module Pi
  module Eventstore

    class Fetcher

      def initialize(connection)
        @connection = connection
      end

      def fetch(uri, etag, on_error: nil)
        loop do
          begin
            response = @connection.get(uri, etag)
            return response if response.status == 200
            code = response.status
            msg = response.body
          rescue Faraday::Error => ex
            code = 502
            msg = ex.message
          end
          on_error.call(code, msg) if on_error
        end
      end

    end

  end
end

