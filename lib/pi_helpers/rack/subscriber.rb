# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'faraday'
require 'es_readmodel/subscriber'
require_relative './json_response'

module Pi
  module Rack

    class Subscriber

      attr_reader :status

      def initialize(app, options)
        @app = app
        @listener = options[:listener]
        @subscriber = EsReadModel::Subscriber.new(options)
        @upstream = options[:upstream]
        @waiting = true
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

      def call(env)
        return busy_response if @waiting
        env['readmodel.available'] = @subscriber.status[:available]
        env['readmodel.state'] = @subscriber.state
        env['readmodel.status'] = 'OK'
        @app.call(env)
      end

      private

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

      def busy_response
        Pi::Rack.respond(503, {
          meta: { origin: self.class.name },
          errors: [
            {
              status: '503',
              title: 'Waiting for upstream service',
              detail: "Upstream service #{@upstream[:host]} not ready"
            }
          ]
        })
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

