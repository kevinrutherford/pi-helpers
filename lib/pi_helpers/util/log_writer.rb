# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Util

    class LogWriter

      def initialize(out = STDERR)
        @out = out
      end

      def call(evt)
        evt = {
          time: Time.now
        }.merge(evt)
        @out.puts evt.map {|k,v| format(k, v.to_s) }.join(' ')
      end

      private

      def format(k, v)
        "#{k}=\"#{v}\""
      end

    end

  end
end

