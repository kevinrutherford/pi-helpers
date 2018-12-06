# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require 'json'

module Pi
  module Rack

    class RequirePrivilege

      def initialize(successor, priv)
        @successor = successor
        @priv = priv.to_s
      end

      def call(env)
        @request = ::Rack::Request.new(env)
        claims = env['pi.claims']
        return error(509, "Incorrect Rack configuration") unless claims
        return error(403, "Privilege #{@priv} required") unless claims.has_key?('privileges')
        return error(403, "Privilege #{@priv} required") unless claims['privileges'].include?(@priv)
        @successor.call(env)
      end

      private

      def error(status_code, message)
        result = { error: message }
        ::Rack::Response.new(result.to_json, status_code)
      end

    end

  end
end

