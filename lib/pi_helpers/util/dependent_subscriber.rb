# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'faraday'
require_relative '../eventstore'

module Pi
  module Util

    class DependentSubscriber

      def initialize(options)
        @listener = options[:listener]
        raise "options[:listener] is required" unless @listener
        @upstream = options[:upstream]
        @subscriber = options[:subscriber] || Pi::Eventstore::Subscriber.new(options)
        @waiting = true
      end

      def start
        wait_for(@upstream) if @upstream
        @listener.call({
          level: 'info',
          tag: 'subscriber.start',
          msg: 'Starting EventStore subscriber'
        })
        @waiting = false
        @subscriber.subscribe
      end

      def info
        {
          status: @waiting ? 503 : @subscriber.status,                 # must be an integer HTTP status code
          state: @subscriber.state
        }
      end

      private

      def available
        @subscriber.status[:available]
      end

      def wait_for(upstream)
        host = upstream[:host]
        @listener.call({
          level: 'info',
          tag: 'waitfor.upstream',
          msg: "About to begin polling #{host}",
          upstream: host,
          subscriber: @subscriber.status
        })
        while true do
          sleep 5
          status = fetch(host, upstream[:path])
          return unless status == 503
          @listener.call({
            level: 'info',
            tag: 'upstream.notready',
            msg: "Upstream service #{host} returned status #{status}",
            upstream: host
          })
        end
      end

      def fetch(host, path)
        connection = Faraday.new(url: host) do |faraday|
          faraday.request :retry, max: 4, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2
          faraday.adapter Faraday.default_adapter
        end
        response = connection.send(:get, path) do |req|
          req.headers = {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
          }
        end
        response.status
      end

    end

  end
end

