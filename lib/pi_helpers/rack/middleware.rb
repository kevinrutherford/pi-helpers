# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require 'es_http_client'

module Xpsurgery

  class StripParams
    def initialize(succ)
      @succ = succ
    end

    def call(env)
      if env.has_key?('router.params')
        env['router.params'].transform_values! {|v| xform(v) }
      end
      @succ.call(env)
    end

    private

    def xform(v)
      String === v ? v.strip : v
    end
  end

  class JsonResponse
    def initialize(succ)
      @succ = succ
    end

    def call(env)
      status, body = @succ.call(env)
      request = Rack::Request.new(env)
      content = body.merge({ self: request.fullpath })
      [status, {'Content-Type' => 'application/json'}, [content.to_json]]
    end
  end

  class RaiseEvent
    def initialize(succ, options)
      @options = options
      @succ = succ
    end

    def call(env)
      event = EsHttpClient.create_event(@options[:type], env['xps.event_data'])
      resource = env['xps.resource']
      expected_version = @options[:version] || EsHttpClient::ExpectedVersion::Any
      if !resource.append(event, expected_version)
        return [409, {errors: ["Conflict -- resource #{resource} in use"]}]
      end
      @succ.call(env)
    end
  end

  class ReturnEmptyResponse
    def call(env)
      [200, {}]
    end
  end

end

