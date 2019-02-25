# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require_relative './json_response'
require_relative '../util/log_writer'

module Pi
  module Rack

    LOGWRITER_KEY = 'pi.logger'

    class RequestLogger

      def initialize(app, options = {})
        @app = app
        @writer = options[:writer] || Pi::Util::LogWriter.new
      end

      def call(env)
        env[LOGWRITER_KEY] = @writer
        req = ::Rack::Request.new(env)
        response = @app.call(env)
        @writer.call({
          level:  'info',
          tag:    'http.request',
          msg:    "#{env['REQUEST_METHOD']} #{req.fullpath}",
          status: response.to_a[0]
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

