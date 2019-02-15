# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'es_http_client'

module Pi
  module Rack

    class ConnectToEventstore

      def initialize(app, options)
        @app = app
        @url = options[:url]
        @username = options[:username]
        @password =  options[:password]
      end

      def call(env)
        env['pi.eventstore'] ||= EsHttpClient.connect(@url, @username, @password)
        @app.call(env)
      end

    end

  end
end

