# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack/response'

module Pi
  module Rack
    class ReadmodelReady

      def initialize(app)
        @app = app
      end

      def call(env)
        return Pi::Rack.respond(503, {
          meta: { origin: self.class.name },
          errors: [
            {
              status: '503',
              title: 'Read model not ready'
            }
          ]
        }) unless env['readmodel.available']
        @app.call(env)
      end

    end


  end
end

