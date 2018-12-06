# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    class ReturnEmptyResponse
      def call(env)
        [200, {}]
      end
    end

  end
end

