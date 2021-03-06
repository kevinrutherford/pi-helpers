# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/unpack_claims'

RSpec.describe Pi::Rack::UnpackClaims do
  let(:app) { Pi::Test::AppShunt.new }
  let(:key_file) { random_word }
  subject { Pi::Rack::UnpackClaims.new(app, key_file) }
  let(:env) {
    {
    }
  }
  let(:shim) { double('Pi::Util::Claims') }

  before do
    allow(Pi::Util::Claims).to receive(:new).and_return(shim)
  end

  context 'when the claims are valid' do
    let(:claims) { random_word }

    before do
      allow(shim).to receive(:parse).with(env).and_return([200, claims])
      @response = subject.call(env)
    end

    specify 'the app is called' do
      expect(app).to be_called
    end

    specify 'the claims are passed down to the app' do
      expect(app.env_passed[Pi::Rack::PRINCIPAL_KEY]).to eq(claims)
    end
  end

  context 'when the claims are not valid' do

    before do
      allow(shim).to receive(:parse).with(env).and_return([403, random_word])
      @response = subject.call(env)
    end

    specify 'an error status us returned' do
      expect(@response.status).to eq(403)
    end

    specify 'the app is not called' do
      expect(app).to_not be_called
    end
  end

end

