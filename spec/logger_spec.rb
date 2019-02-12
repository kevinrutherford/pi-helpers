# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/logger'
require 'pi_helpers/test/app_shunt'

RSpec.describe Pi::Rack::Logger do
  let(:app) { Pi::Test::AppShunt.new }
  let(:priv) { :privilege }
  subject { Pi::Rack::Logger.new(app) }
  let(:response) { subject.call(env) }

  context 'when the app works without problems' do
    let(:env) { { } }

    specify 'a 200 response is returned' do
      expect(response.status).to eq(200)
    end

    specify 'the app is called' do
      response
      expect(app).to be_called
    end

  end

end

