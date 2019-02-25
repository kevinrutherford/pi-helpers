# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'es_http_client'
require_relative './configuration_error'
require_relative './json_response'

module Pi
  module Rack

    EVENT_DATA_KEY = 'pi.event_data'
    RESOURCE_KEY = 'pi.resource'

    class RaiseEvent
      def initialize(succ, options)
        @options = options
        @succ = succ
      end

      def call(env)
        raise ConfigurationError, "Environment must contain event data" unless env[EVENT_DATA_KEY]
        raise ConfigurationError, "Environment must define a resource" unless env[RESOURCE_KEY]
        event = EsHttpClient.create_event(@options[:type], env[EVENT_DATA_KEY])
        resource = env[RESOURCE_KEY]
        expected_version = @options[:version] || EsHttpClient::ExpectedVersion::Any
        if !resource.append(event, expected_version)
          return Pi::Rack.respond(409, {
            errors: [
              {
                status: '409',
                title: "Conflict -- resource #{resource} in use"
              }
            ]
          })
        end
        @succ.call(env)
      end
    end

  end
end

