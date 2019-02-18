# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require 'json'
require_relative './json_response'

module Pi
  module Rack

    class RequirePrivilege

      def initialize(app, priv)
        @app = app
        @priv = priv.to_s
      end

      def call(env)
        @request = ::Rack::Request.new(env)
        claims = env['pi.claims']
        return error(509, "Incorrect Rack configuration") unless claims
        return error(403, "Privilege #{@priv} required") unless claims.has_key?('privileges')
        return error(403, "Privilege #{@priv} required") unless claims['privileges'].include?(@priv)
        @app.call(env)
      end

      private

      def error(status, message)
        result = { error: message }
        Pi::Rack.respond(status, result)
      end

    end

  end
end

