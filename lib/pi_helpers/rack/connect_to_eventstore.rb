# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'es_http_client'

module Pi
  module Rack

    EVENTSTORE_KEY = 'pi.eventstore'

    class ConnectToEventstore

      def initialize(app, options)
        @app = app
        @url = options[:url]
        @username = options[:username]
        @password =  options[:password]
      end

      def call(env)
        env[EVENTSTORE_KEY] ||= EsHttpClient.connect(@url, @username, @password)
        @app.call(env)
      end

    end

  end
end

