# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'json'
require 'jwt'
require_relative './json_response'

module Pi
  module Rack

    CLAIMS_KEY = 'pi.claims'

    class UnpackClaims

      def initialize(app, key_file)
        @app = app
        @verify_key = ""
        File.open(key_file) {|f| @verify_key = OpenSSL::PKey.read(f) }
      end

      def call(env)
        @request = ::Rack::Request.new(env)
        with_claims(env) do |claims|
          env[CLAIMS_KEY] = claims
          @app.call(env)
        end
      end

      private

      def with_claims(env)
        auth_header = env['HTTP_AUTHORIZATION']
        return error(401, 'No Authorization header found') if auth_header.nil?
        m = /^Bearer (.*)$/.match(auth_header)
        return error(401, 'Bearer not found') if m.nil?
        bearer = m[1]
        begin
          claims = JWT.decode(bearer, @verify_key, true, { algorithm: 'RS256' })[0]
          return yield claims
        rescue JWT::DecodeError => ex
          return error(403, ex.message)
        end
      end

      def error(status, message)
        Pi::Rack.respond(status, { error: message })
      end

    end

  end
end

