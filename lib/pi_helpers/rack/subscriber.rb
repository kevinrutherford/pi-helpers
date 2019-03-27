# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative '../util/dependent_subscriber'
require_relative '../rack/json_response'

module Pi
  module Rack

    READMODEL_KEY = 'pi.readmodel'

    class Subscriber

      def initialize(app, options)
        @app = app
        @subscriber = options[:subscriber] || Pi::Util::DependentSubscriber.new(options)
        raise 'Subscriber must respond to :info' unless @subscriber.respond_to?(:info)
        raise 'Subscriber must respond to :start' unless @subscriber.respond_to?(:start)
        Thread.new { @subscriber.start }
      end

      def call(env)
        info = @subscriber.info
        if env['PATH_INFO'] == '/info'
          return Pi::Rack.respond(200, {
            data: {
              type: 'ServiceStatus',
              attributes: info
            }
          })
        end
        code = info[:status_code]
        if code != 200
          return Pi::Rack.respond(code, {
            errors: [
              {
                status: code.to_s,
                title: 'Eventstore subscriber not available'
              }
            ]
          })
        end
        env[READMODEL_KEY] = info
        @app.call(env)
      end

    end

  end
end

