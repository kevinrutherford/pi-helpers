# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/subscriber'

RSpec.describe Pi::Rack::Subscriber do
  let(:app) { Pi::Test::AppShunt.new }
  let(:piggy) { double('Piggy-back subscriber', start: true) }
  subject { Pi::Rack::Subscriber.new(app, options) }
  let(:options) {
    {
      subscriber: piggy
    }
  }
  let(:env) {
    {
      random_word => random_id,
      random_word => random_id,
      random_word => random_id
    }
  }

  before do
    expect(piggy).to receive(:info).and_return({ status_code: subscriber_status })
    @response = subject.call(env)
  end

  context 'when the subscriber is okay' do
    let(:subscriber_status) { 200 }

    specify 'the env is passed down to the app' do
      expect(app).to be_called
      expect(app.env_passed).to eq(env)
    end

    specify 'the app response is returned upwards' do
      json = JSON.parse(@response.body[0])
      expect(json).to eq(app.response)
    end

  end

  context 'when the subscriber is reporting a problem' do
    let(:subscriber_status) { 502 }

    specify 'the subscriber status is returned' do
      expect(@response.status).to eq(subscriber_status)
    end

    specify 'the app is not called' do
      expect(app).to_not be_called
    end
  end

  describe '/info' do
    let(:subscriber_status) { random_int }
    let(:env) {
      {
        'PATH_INFO' => '/info'
      }
    }

    specify 'the request succeeds' do
      expect(@response.status).to eq(200)
    end

    specify 'the subscriber status is returned' do
      json = JSON.parse(@response.body[0], symbolize_names: true)
      expect(json[:data][:attributes][:status_code]).to eq(subscriber_status)
    end

    specify 'the app is not called' do
      expect(app).to_not be_called
    end
  end

end

