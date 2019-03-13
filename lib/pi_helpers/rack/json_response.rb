# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require 'json'
require_relative './configuration_error'

module Pi
  module Rack

    def respond(status, body)
      if body.nil?
        content = []
      else
        raise ConfigurationError,'Response body must be a Hash' unless Hash === body
        content = body.to_json
      end
      result = ::Rack::Response.new(content, status)
      result.set_header('Content-Type', 'application/json')
      result
    end

    module_function :respond

  end
end

