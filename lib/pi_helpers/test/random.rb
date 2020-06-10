# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'uuidtools'
require 'securerandom'

module Pi
  module Test

    module Random

      def random_int
        ::Random.rand(1000) + 1
      end

      def random_word(pattern = '%')
        mixer = SecureRandom.hex(10)
        pattern.gsub(/%/, mixer)
      end

      def random_id
        UUIDTools::UUID.random_create.to_s
      end

      def random_email_address
        "#{random_word}@#{random_word}.com"
      end

      module_function :random_int, :random_word, :random_id, :random_email_address

    end
  end
end

