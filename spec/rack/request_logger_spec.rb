# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/request_logger'
require 'pi_helpers/test/app_shunt'

RSpec.describe Pi::Rack::RequestLogger do
  let(:out) { StringIO.new }
  let(:writer) { Pi::Util::LogWriter.new(out) }
  subject { Pi::Rack::RequestLogger.new(app, writer: writer) }
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

    specify 'the response is logged' do
      response
      expect(out.string).to match(/status="200"/)
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

