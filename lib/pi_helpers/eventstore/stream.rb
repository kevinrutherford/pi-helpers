# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './page'
require_relative './fetcher'

module Pi
  module Eventstore

    class Stream

      def Stream.open(name, connection, info, listener)
        Stream.new("/streams/#{name}", connection, info, listener)
      end

      def initialize(head_uri, connection, info, listener)
        @connection = connection
        @info = info
        @listener = listener
        @current_etag = nil
        @original_status_code = info[:status_code]
        @retry_interval = 60
        fetch_first_page(head_uri)
      end

      def wait_for_new_events
        while @current_page.empty?
          sleep 1
          fetch(@current_uri)
        end
      end

      def each_event(&blk)
        while !@current_page.empty?
          @current_page.each_event(&blk)
          fetch(@current_page.newer_events_uri) if @current_page.newer_events_uri
        end
      end

      private

      def fetch_first_page(uri)
        @listener.call(connecting(uri))
        fetch(uri)
        last = @current_page.first_event_uri
        fetch(last) if last
        @listener.call(connected(uri))
      end

      def fetch(uri)
        response = Fetcher.new(@connection).fetch(uri, @current_etag, on_error: ->(code, msg) {
          @info[:status_code] = code
          @info[:message] = msg
          @listener.call(fetch_failed(uri, code, msg))
          sleep @retry_interval
        })
        @info[:status_code] = @original_status_code
        @current_page = Page.new(response.body)
        @current_uri = uri
        @current_etag = response.headers['etag']
      end

      def connecting(uri)
        {
          level: 'info',
          tag:   'fetchFirstPage.connecting',
          msg:   "Connecting to #{uri} on #{@connection}"
        }
      end

      def connected(uri)
        {
          level: 'info',
          tag:   'fetchFirstPage.connected',
          msg:   "Connected to #{uri} on #{@connection}",
          eventsWaiting: !@current_page.empty?
        }
      end

      def fetch_failed(uri, code, msg)
        {
          level: 'error',
          tag: 'eventstore.error',
          msg: "Failed to fetch from Eventstore. Retrying in #{@retry_interval}s",
          uri: uri,
          status_code: code,
          error: msg
        }
      end

    end

  end
end

