# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require_relative './json_response'
require_relative './log_writer'

module Pi
  module Rack

    class Logger

      def initialize(app)
        @app = app
        @writer = LogWriter.new
      end

      def call(env)
        env['pi.logger'] = @writer
        req = ::Rack::Request.new(env)
        res = @app.call(env)
        @writer.call({
          level:  'info',
          tag:    'http.request',
          msg:    "#{env['REQUEST_METHOD']} #{req.fullpath}",
          status: res.status
        })
        res
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

