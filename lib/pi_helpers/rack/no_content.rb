# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './json_response'

module Pi
  module Rack

    class NoContent

      def call(env)
        Pi::Rack.respond(204, nil)
      end
    end

  end
end

