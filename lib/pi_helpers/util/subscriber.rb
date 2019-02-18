# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'faraday'
require 'es_readmodel/subscriber'

module Pi
  module Util

    class Subscriber

      def initialize(options)
        @listener = options[:listener]
        @upstream = options[:upstream]
        @subscriber = EsReadModel::Subscriber.new(options)
        @waiting = true
      end

      def start
        Thread.new do
          wait_for(@upstream) if @upstream
          @listener.call({
            level: 'info',
            tag: 'subscriber.start',
            msg: 'Starting EventStore subscriber'
          })
          @waiting = false
          @subscriber.subscribe
        end
      end

      def status
        {
          available:      !@waiting && available,
          state:          @subscriber.state,
          status_message: status_message
        }
      end

      private

      def available
        @subscriber.status[:available]
      end

      def status_message
        return "Waiting for upstream service #{@upstream[:host]} to start" if @waiting
        available ? 'OK' : 'Catching up with recent events'
      end

      def wait_for(upstream)
        host = upstream[:host]
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

