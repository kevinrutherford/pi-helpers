# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'faraday'

module Pi
  module Util

    class Upstream

      def initialize(host, path)
        @host = host
        @path = path
      end

      def check
        connection = Faraday.new(url: @host) do |faraday|
          faraday.request :retry, max: 4, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2
          faraday.response :json, content_type: 'application/json'
          faraday.adapter Faraday.default_adapter
        end
        response = connection.send(:get, @path) do |req|
          req.headers = {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
          }
        end
        if response.status == 200
          { status_code: response.body['data']['attributes']['status_code'] }
        else
          { status_code: response.status }
        end
      rescue Exception => ex
        {
          status_code: 502,
          message: ex.message
        }
      end

    end

  end
end

