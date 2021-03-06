# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './event'

module Pi
  module Eventstore

    class Page

      def initialize(body, page_size)
        @body = body
        @page_size = page_size
      end

      def first_event_uri
        uri = find_link('last')
        uri.nil? ? nil : uri.gsub(/\/20$/, "/#{@page_size}")
      end

      def newer_events_uri
        find_link('previous')
      end

      def empty?
        @body['entries'].nil? || @body['entries'].empty?
      end

      def each_event(&block)
        @body['entries']
          .reverse!
          .map {|e| Event.load_from(e)}
          .compact
          .select {|e| e.type !~ /^\$/ }
          .each {|e| yield e }
      end

      private

      def find_link(rel)
        link = @body['links'].detect { |l| l['relation'] == rel }
        link.nil? ? nil : link['uri']
      end

    end

  end
end

