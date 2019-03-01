# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'

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
        query_string = ::Rack::Request.new(env).GET
        env[PARAMS_KEY] = strip_values(router_params).merge(symbolize_keys(query_string))
        @app.call(env)
      end

      private

      def strip_values(h)
        h.transform_values {|v| strip(v) }
      end

      def strip(v)
        String === v ? v.strip : v
      end

      def symbolize_keys(h)
        h.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end

    end

  end
end

