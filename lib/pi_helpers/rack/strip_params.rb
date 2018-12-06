# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    class StripParams
      def initialize(succ)
        @succ = succ
      end

      def call(env)
        if env.has_key?('router.params')
          env['pi.params'] = env['router.params'].transform_values {|v| xform(v) }
        end
        @succ.call(env)
      end

      private

      def xform(v)
        String === v ? v.strip : v
      end
    end

  end
end

