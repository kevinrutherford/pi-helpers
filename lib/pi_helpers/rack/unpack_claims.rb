# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './json_response'
require_relative '../util/claims'

module Pi
  module Rack

    CLAIMS_KEY = 'pi.claims'

    class UnpackClaims

      def initialize(app, key_file)
        @key_file = key_file
        @app = app
      end

      def call(env)
        parse_result = Pi::Util::Claims.new(@key_file).parse(env)
        status = parse_result[0]
        if status == 200
          env[CLAIMS_KEY] = parse_result[1]
          @app.call(env)
        else
          Pi::Rack.respond(status, {
            errors: [
              status: status.to_s,
              title: parse_result[1]
            ]
          })
        end
      end

    end

  end
end

