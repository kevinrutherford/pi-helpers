# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    PARAMS_KEY = 'pi.params'

    class StripParams
      def initialize(app)
        @app = app
      end

      def call(env)
        router_params_key = 'router.params'
        router_params = env[router_params_key]
        raise ConfigurationError, "Environment must include #{router_params_key}" unless router_params
        env[PARAMS_KEY] = router_params.transform_values {|v| xform(v) }
        @app.call(env)
      end

      private

      def xform(v)
        String === v ? v.strip : v
      end
    end

  end
end

