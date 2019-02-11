# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

module Pi
  module Rack

    def respond(status, body)
      content = body.nil? ? [] : body.to_json
      result = ::Rack::Response.new(content, status)
      result.set_header('Content-Type', 'application/json')
      result
    end

    module_function :respond

  end
end

