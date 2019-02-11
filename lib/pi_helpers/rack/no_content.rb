# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    class NoContent

      def call(env)
        Pi::Rack.respond(204, nil)
      end
    end

  end
end

