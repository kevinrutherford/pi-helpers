# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

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
        status, headers, body = @app.call(env)
        @writer.call({
          level:  'info',
          tag:    'http.request',
          msg:    "#{env['REQUEST_METHOD']} #{@request.fullpath}",
          status: status
          })
        [status, headers, body]
      end

    end

  end
end

