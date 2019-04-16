# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/check_for_claims'

RSpec.describe Pi::Rack::CheckForClaims do
  let(:app) { Pi::Test::AppShunt.new }
  let(:key_file) { random_word }
  subject { Pi::Rack::CheckForClaims.new(app, key_file) }
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
      expect(app.env_passed[Pi::Rack::CLAIMS_KEY]).to eq(claims)
    end
  end

  context 'when the claims are not valid' do

    before do
      allow(shim).to receive(:parse).with(env).and_return([403, random_word])
      @response = subject.call(env)
    end

    specify 'the app is called' do
      expect(app).to be_called
    end

    specify 'the claims are not passed down to the app' do
      expect(app.env_passed).to_not have_key(Pi::Rack::CLAIMS_KEY)
    end
  end

end

