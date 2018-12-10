# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
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
        'pi.resource' => resource,
        'pi.event_data' => {}
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

end

