# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative '../eventstore'
require_relative './upstream'

module Pi
  module Util

    class DependentSubscriber

      def initialize(options)
        @listener = options[:listener]
        raise 'options[:listener] is required' unless @listener
        @upstream = options[:upstream]
        if @upstream
          raise 'upstream[:host] is required' unless @upstream[:host]
          raise 'upstream[:path] is required' unless @upstream[:path]
          raise 'upstream[:grace_period] is required' unless @upstream[:grace_period]
          raise 'upstream[:interval] is required' unless @upstream[:interval]
        end
        @info = {
          status_code: 503,
          message: 'OK',
          state: nil,
          stats: {}
        }
        @subscriber = options[:test_subscriber] || Pi::Eventstore::Subscriber.new(@info, options[:eventstore], @listener)
      end

      def start
        @listener.call(starting_service)
        if @upstream
          wait_for(@upstream)
          return @listener.call(not_starting_subscriber) unless @info[:status_code] == 200
        end
        @listener.call(starting_subscriber)
        @info[:status_code] = 200
        @subscriber.subscribe
        @listener.call(subscriber_stopped)
      end

      def info
        @info
      end

      private

      def wait_for(upstream)
        @info[:status_code] = 503
        @info[:message] = "Waiting for upstream #{@upstream[:host]} service"
        sleep @upstream[:grace_period]
        upstream = Upstream.new(@upstream[:host], @upstream[:path])
        loop do
          @info.merge! upstream.check
          log_upstream_status
          return unless @info[:status_code] == 503
          sleep @upstream[:interval]
        end
      end

      def log_upstream_status
        host = @upstream[:host]
        code = @info[:status_code]
        msg = @info[:message]
        @listener.call({
          level: 'info',
          tag: 'upstream.status',
          msg: "Upstream service #{host} status: #{code}",
          upstream: host,
          message: msg
        })
      end

      def starting_service
        {
          level: 'info',
          tag: 'service.start',
          msg: 'Starting dependent subscriber'
        }
      end

      def starting_subscriber
        {
          level: 'info',
          tag: 'subscriber.start',
          msg: 'Starting EventStore subscriber'
        }
      end

      def not_starting_subscriber
        {
          level: 'error',
          tag: 'subscriber.notstarted',
          msg: "Not starting EventStore subscriber: #{@info[:message]}"
        }
      end

      def subscriber_stopped
        {
          level: 'error',
          tag: 'subscriber.stopped',
          msg: "EventStore subscriber stopped: #{@info[:message]}"
        }
      end

    end

  end
end

