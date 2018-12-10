# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    def respond(status, body)
      result = ::Rack::Response.new(body.to_json, status)
      result.set_header('Content-Type', 'application/json')
      result
    end

    module_function :respond

  end
end

