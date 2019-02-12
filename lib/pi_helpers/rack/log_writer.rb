# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    class LogWriter

      def call(ctx)
        ctx = {
          time: Time.now
        }.merge(ctx)
        extras = ENV.select {|k,v| k =~ /^readmodel/i }
        ctx = ctx.merge(extras)
        STDERR.puts ctx.map {|k,v| format(k, v.to_s) }.join(' ')
      end

      private

      def format(k, v)
        value = (v =~ / /) ? "\"#{v}\"" : v
        "#{k}=#{value}"
      end

    end

  end
end

