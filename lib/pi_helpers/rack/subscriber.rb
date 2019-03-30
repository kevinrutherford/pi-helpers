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
        code = info[:status_code]
        return not_available(code) if code != 200
        return service_status(info) if env['PATH_INFO'] == '/info'
        env[READMODEL_KEY] = info
        @app.call(env)
      end

      private

      def service_status(info)
        Pi::Rack.respond(200, {
          data: {
            type: 'ServiceStatus',
            attributes: info.reject {|k,v| k == :state }
          }
        })
      end

      def not_available(code)
        Pi::Rack.respond(code, {
          errors: [
            {
              status: code.to_s,
              title: 'Eventstore subscriber not available'
            }
          ]
        })
      end

    end

  end
end

