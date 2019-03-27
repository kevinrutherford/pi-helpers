# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './page'

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
        if @info[:status_code] == 200
          last = @current_page.first_event_uri
          fetch(last) if last
          @listener.call(connected(uri))
        end
      end

      def fetch(uri)
        response = @connection.get(uri, @current_etag)
        @info[:status_code] = response.status
        @current_page = Page.new(response.body)
        @current_uri = uri
        @current_etag = response.headers['etag']
      rescue Exception => ex
        @info[:status_code] = 502
        @info[:message] = ex.message
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

    end

  end
end

