# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './json_response'
require_relative '../util/claims'
require_relative './unpack_claims'

module Pi
  module Rack

    class CheckForClaims

      def initialize(app, key_file)
        @key_file = key_file
        @app = app
      end

      def call(env)
        parse_result = Pi::Util::Claims.new(@key_file).parse(env)
        status = parse_result[0]
        env[Pi::Rack::PRINCIPAL_KEY] = parse_result[1] if status == 200
        @app.call(env)
      end

    end

  end
end

