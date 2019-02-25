# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative '../util/subscriber'

module Pi
  module Rack

    READMODEL_KEY = 'pi.readmodel'

    class Subscriber

      def initialize(app, options)
        @app = app
        @subscriber = Pi::Util::Subscriber.new(options)
        Thread.new { @subscriber.start }
      end

      def call(env)
        env[READMODEL_KEY] = @subscriber.status
        @app.call(env)
      end

    end

  end
end

