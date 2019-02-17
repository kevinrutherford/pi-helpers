# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require_relative './json_response'
require_relative '../util/log_writer'

module Pi
  module Rack

    class Logger

      def initialize(app)
        @app = app
        @writer = Pi::Util::LogWriter.new
      end

      def call(env)
        env['pi.logger'] = @writer
        req = ::Rack::Request.new(env)
        response = @app.call(env)
        case response
        when ::Rack::Response
          status = response.status
        when Array
          @writer.call({
            level:  'warning',
            tag:    'array.response',
            msg:    "Array returned instead of Rack::Response",
            response: response.inspect
          })
          status = response[0]
        else
          @writer.call({
            level:  'warning',
            tag:    'unknown.response',
            msg:    "#{response.class.name} returned instead of Rack::Response",
            response: response.inspect
          })
          status = 'unknown'
        end
        @writer.call({
          level:  'info',
          tag:    'http.request',
          msg:    "#{env['REQUEST_METHOD']} #{req.fullpath}",
          status: status
        })
        response
      rescue Exception => ex
        @writer.call({
          level: 'error',
          tag: 'internal.error',
          msg: ex.message,
          classname: ex.class.name,
          stacktrace: ex.backtrace,
          request: "#{env['REQUEST_METHOD']} #{req.fullpath}",
        })
        Pi::Rack.respond(500, {
          meta: { origin: self.class.name },
          errors: [
            {
              status: '500',
              title: 'Internal server error',
              detail: ex.message
            }
          ]
        })
      end

    end

  end
end

