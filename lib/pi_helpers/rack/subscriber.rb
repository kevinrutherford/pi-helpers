# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative '../util/subscriber'
require_relative './json_response'

module Pi
  module Rack

    class Subscriber

      def initialize(app, options)
        @app = app
        @subscriber = Pi::Util::Subscriber.new(options)
        Thread.new { @subscriber.start }
      end

      def call(env)
        env[ENV_READMODEL] = @subscriber.status
        @app.call(env)
      end

    end

  end
end

