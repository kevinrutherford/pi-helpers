# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'json'
require 'jwt'

module Pi
  module Rack

    class UnpackClaims

      def initialize(successor, key_file)
        @successor = successor
        @verify_key = ""
        File.open(key_file) {|f| @verify_key = OpenSSL::PKey.read(f) }
      end

      def call(env)
        @request = ::Rack::Request.new(env)
        with_claims(env) do |claims|
          env['pi.claims'] = claims
          @successor.call(env)
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

      def error(status_code, message)
        result = { error: message }
        [
          status_code,
          { 'Content-Type' => 'application/json' },
          [result.to_json]
        ]
      end

    end

  end
end

