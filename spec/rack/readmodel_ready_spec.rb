# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack'

RSpec.describe Pi::Rack::ReadmodelReady do
  let(:app) { Pi::Test::AppShunt.new }
  subject { Pi::Rack::ReadmodelReady.new(app) }

  context 'when the readmodel is ready' do
    let(:env) {
      {
        Pi::Rack::READMODEL_KEY => { available: true }
      }
    }

    before do
      @response = subject.call(env)
    end

    specify 'the app is called' do
      expect(app).to be_called
    end

    specify "the app's response is returned" do
      json = JSON.parse(@response.body[0])
      expect(json).to eq(app.response)
    end
  end

  context 'when the readmodel is not ready' do
    let(:env) {
      {
        Pi::Rack::READMODEL_KEY => { available: false }
      }
    }

    before do
      @response = subject.call(env)
    end

    specify 'a 503 error is returned' do
      expect(@response.status).to eq(503)
    end

    specify 'the app is not called' do
      expect(app).to_not be_called
    end
  end

  context 'when there is no readmodel' do
    let(:env) { { } }

    specify 'an exception is thrown' do
      expect { subject.call(env) }.to raise_exception(Pi::Rack::ConfigurationError)
      expect(app).to_not be_called
    end
  end

end

