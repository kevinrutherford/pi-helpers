# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Util

    class Principal

      def initialize(claims)
        @claims = claims
      end

      def company_id
        @claims['companyId']
      end

      def user_id
        @claims['userId']
      end

      def created_at
        @claims['iat']
      end

      def expires_at
        @claims['exp']
      end

      def can(priv)
        @claims['privileges'].include?(priv.to_s)
      end

    end

  end
end

