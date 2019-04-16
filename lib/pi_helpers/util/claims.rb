# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'jwt'

module Pi
  module Util

    class Claims

      def initialize(key_file)
        @verify_key = ""
        File.open(key_file) {|f| @verify_key = OpenSSL::PKey.read(f) }
      end

      def parse(env)
        auth_header = env['HTTP_AUTHORIZATION']
        return [401, 'No Authorization header found'] if auth_header.nil?
        m = /^Bearer (.*)$/.match(auth_header)
        return [401, 'Bearer not found'] if m.nil?
        bearer = m[1]
        begin
          claims = JWT.decode(bearer, @verify_key, true, { algorithm: 'RS256' })[0]
          return [200, claims]
        rescue JWT::DecodeError => ex
          return [403, ex.message]
        end
      end

    end

  end
end

