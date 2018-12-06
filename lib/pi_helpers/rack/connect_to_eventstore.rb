# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'es_http_client'

module Pi
  module Rack

    class ConnectToEventstore

      def initialize(successor, options)
        @successor = successor
        @url = options[:url]
        @username = options[:username]
        @password =  options[:password]
      end

      def call(env)
        env['pi.eventstore'] ||= EsHttpClient.connect(@url, @username, @password)
        @successor.call(env)
      end

    end

  end
end

