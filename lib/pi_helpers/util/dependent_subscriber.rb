# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative '../eventstore'

module Pi
  module Util

    class DependentSubscriber

      def initialize(options)
        @listener = options[:listener]
        raise "options[:listener] is required" unless @listener
        @upstream = options[:upstream]
        @subscriber = options[:eventstore] || Pi::Eventstore::Subscriber.new(@info, options[:eventstore], @listener)
        @info = {
          status_code: 200,
          message: 'OK',
          state: nil,
          stats: {}
        }
      end

      def start
        wait_for(@upstream) if @upstream
        if @info[:status_code] == 200
          @listener.call(starting_subscriber)
          @subscriber.subscribe
          @listener.call(subscriber_stopped)
        else
          @listener.call(not_starting_subscriber)
        end
      end

      def info
        @info
      end

      private

      def wait_for(upstream)
        @info[:status_code] = 503
        @info[:message] = "Waiting for upstream #{@upstream[:host]} service"
        sleep @options[:upstream][:grace_period]
        upstream = Upstream.new(@options[:upstream], @info)
        loop do
          @info.merge! upstream.check
          log_upstream_status
          return unless @info[:status_code] == 503
          sleep @options[:upstream][:interval]
        end
      end

      def log_upstream_status
        host = @options[:upstream][:host]
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

