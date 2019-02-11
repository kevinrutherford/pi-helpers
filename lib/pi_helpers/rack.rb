# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rack'
require_relative 'rack/connect_to_eventstore'
require_relative 'rack/no_content'
require_relative 'rack/raise_event'
require_relative 'rack/readmodel_ready'
require_relative 'rack/require_privilege'
require_relative 'rack/strip_params'
require_relative 'rack/unpack_claims'

module Pi
  module Rack
  end
end

