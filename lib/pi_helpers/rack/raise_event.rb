# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'es_http_client'
require_relative './json_response'

module Pi
  module Rack

    class RaiseEvent
      def initialize(succ, options)
        @options = options
        @succ = succ
      end

      def call(env)
        event = EsHttpClient.create_event(@options[:type], env['pi.event_data'])
        resource = env['pi.resource']
        expected_version = @options[:version] || EsHttpClient::ExpectedVersion::Any
        if !resource.append(event, expected_version)
          return Pi::Rack.respond(409, {errors: ["Conflict -- resource #{resource} in use"]})
        end
        @succ.call(env)
      end
    end

  end
end

