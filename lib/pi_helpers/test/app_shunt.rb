# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Test

    class AppShunt

      attr_reader :env_passed

      def initialize
        @called = false
      end

      def called?
        @called
      end

      def call(env)
        @called = true
        @env_passed = env
        return response
      end

      def response
        @response ||= {
          Pi::Test::Random::random_id => Pi::Test::Random::random_word,
          Pi::Test::Random::random_id => Pi::Test::Random::random_word
        }
      end

    end

  end
end

