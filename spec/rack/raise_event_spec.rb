# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/raise_event'

RSpec.describe Pi::Rack::RaiseEvent do
  let(:app) { double('App', call: nil) }
  subject { Pi::Rack::RaiseEvent.new(app, {}) }
  let(:response) { subject.call(env) }
  let(:resource) { double('Resource stream') }

  context 'when the event would cause a resource conflict' do
    let(:env) {
      {
        Pi::Rack::RESOURCE_KEY => resource,
        Pi::Rack::EVENT_DATA_KEY => {}
      }
    }

    before do
      allow(resource).to receive(:append).and_return(false)
    end

    specify 'a 409 response is returned' do
      expect(response.status).to eq(409)
    end

    specify 'the app is not called' do
      response
      expect(app).to_not have_received(:call)
    end

  end

  context 'when there is no event data' do
    let(:env) {
      {
        Pi::Rack::RESOURCE_KEY => resource
      }
    }

    specify 'an error is thrown' do
      expect{ subject.call(env) }.to raise_error(Pi::Rack::ConfigurationError)
      expect(app).to_not have_received(:call)
    end
  end

  context 'when there is no resource' do
    let(:env) {
      {
        Pi::Rack::EVENT_DATA_KEY => {}
      }
    }

    specify 'an error is thrown' do
      expect{ subject.call(env) }.to raise_error(Pi::Rack::ConfigurationError)
      expect(app).to_not have_received(:call)
    end
  end

end

