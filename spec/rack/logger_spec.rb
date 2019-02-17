# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/logger'
require 'pi_helpers/test/app_shunt'

RSpec.describe Pi::Rack::Logger do
  subject { Pi::Rack::Logger.new(app) }
  let(:env) { { } }
  let(:response) { subject.call(env) }

  context 'when the app works without problems' do
    let(:app) { Pi::Test::AppShunt.new }

    specify 'a 200 response is returned' do
      expect(response.status).to eq(200)
    end

    specify 'the app is called' do
      response
      expect(app).to be_called
    end

  end

  context 'when the app responds with an array' do
    let(:array) { [503, {}, []] }
    let(:app) {
      ->(env) { array }
    }

    specify 'the array is returned' do
      expect(response).to eq(array)
    end
  end

end

