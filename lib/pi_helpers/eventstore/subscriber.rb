# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './connection'
require_relative './stream'

module Pi
  module Eventstore

    class Subscriber

      def initialize(info, options, listener)
        @info = info
        @listener = listener
        raise 'options[:url] is required' unless options[:url]
        raise 'options[:username] is required' unless options[:username]
        raise 'options[:password] is required' unless options[:password]
        raise 'options[:reducer] is required' unless options[:reducer]
        url = options[:url]
        @info[:stats] = {
          startedAt: Time.now,
          eventsReceived: 0,
          eventStore: url
        }
        @connection = Connection.new(url, options[:username], options[:password])
        @reducer = options[:reducer]
        @retry_secs = options[:retry_secs] || 20
        @page_size = options[:page_size] || 200
      end

      def subscribe
        prevent_readmodel_access
        @stream = Stream.open("$all", @connection, @info, @listener, @retry_secs, @page_size)
        @stream.wait_for_new_events
        process_all
        loop do
          allow_readmodel_access
          @stream.wait_for_new_events
          prevent_readmodel_access
          process_all
        end
      end

      private

      def prevent_readmodel_access
        @info[:status_code] = 503
      end

      def allow_readmodel_access
        @info[:status_code] = 200
      end

      def process_all
        num_events_processed = 0
        @stream.each_event do |evt|
          process(evt)
          num_events_processed += 1
        end
        @info[:stats][:eventsReceived] = @info[:stats][:eventsReceived] + num_events_processed
        @listener.call(caught_up num_events_processed)
      end

      def process(evt)
        @info[:state] = @reducer.call(@info[:state], evt)
      rescue Exception => ex
        @listener.call(reducer_error(ex, evt))
      end

      def reducer_error(ex, evt)
        {
          level: 'error',
          tag:   'reducer.error',
          msg:   "Error in reducer: #{ex.class}: #{ex.message}. Read model state not updated.",
          event: evt.type
        }
      end

      def caught_up(num)
        {
          level: 'info',
          tag:   'subscription.caughtUp',
          msg:   "Subscription to $all caught up",
          eventsProcessed: num
        }
      end

    end

  end
end

