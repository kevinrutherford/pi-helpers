# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require_relative './configuration_error'
require_relative './json_response'

module Pi
  module Rack

    class RequirePrivilege

      def initialize(app, priv)
        @app = app
        @priv = priv
      end

      def call(env)
        principal = env[PRINCIPAL_KEY]
        raise ConfigurationError, "Environment must contain unpacked claims" unless principal
        return error(403, "Privilege #{@priv} required") unless principal.can(@priv)
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

