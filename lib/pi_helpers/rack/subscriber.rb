# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative '../util/subscriber'
require_relative '../rack/json_response'

module Pi
  module Rack

    READMODEL_KEY = 'pi.readmodel'

    class Subscriber

      def initialize(app, options)
        @app = app
        @subscriber = options[:subscriber] || Pi::Util::Subscriber.new(options)
        Thread.new { @subscriber.start }
      end

      def call(env)
        status = @subscriber.status
        code = status[:subscriber]
        if code != 200
          return Pi::Rack.respond(code, {
            errors: [
              {
                status: code.to_s,
                title: 'Eventstore subscriber status',
                detail: status.inspect
              }
            ]
          })
        end
        env[READMODEL_KEY] = status
        @app.call(env)
      end

    end

  end
end

