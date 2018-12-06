# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    class JsonResponse
      def initialize(succ)
        @succ = succ
      end

      def call(env)
        status, body = @succ.call(env)
        request = ::Rack::Request.new(env)
        content = body.merge({ self: request.fullpath })
        [status, {'Content-Type' => 'application/json'}, [content.to_json]]
      end
    end

  end
end

