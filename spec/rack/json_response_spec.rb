# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/json_response'

RSpec.describe Pi::Rack do

  context 'when the body is not a Hash' do
    specify 'it throws an error' do
      expect { Pi::Rack.respond(200, 'hello') }.to raise_error(Pi::Rack::ConfigurationError)
    end
  end

end

