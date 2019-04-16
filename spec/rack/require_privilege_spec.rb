# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/require_privilege'
require 'pi_helpers/util/principal'

RSpec.describe Pi::Rack::RequirePrivilege do
  let(:app) { Pi::Test::AppShunt.new }
  let(:priv) { random_word }
  subject { Pi::Rack::RequirePrivilege.new(app, priv.to_sym) }

  context 'when the claims have not been unpacked' do
    let(:env) { { } }

    specify 'an error is thrown' do
      expect { subject.call(env) }.to raise_error(Pi::Rack::ConfigurationError)
      expect(app).to_not be_called
    end

  end

  context 'when Rack has been configured correctly' do
    let(:env) {
      {
        Pi::Rack::PRINCIPAL_KEY => Pi::Util::Principal.new({ 'privileges' => privs })
      }
    }

    before do
      @response = subject.call(env)
    end

    context 'when the principal has the required privilege' do
      let(:privs) { [ priv ] }

      specify 'the app is called' do
        expect(app).to be_called
      end

      specify 'the original env is passed to the app' do
        expect(app.env_passed).to eq(env)
      end

      specify 'the app response is returned' do
        json = JSON.parse(@response.body[0])
        expect(json).to eq(app.response)
      end

    end

    context 'when the principal does not have the privilege' do
      let(:privs) { [ ] }

      specify 'a 403 error is returned' do
        expect(@response.status).to eq(403)
      end

      specify 'the app is not called' do
        expect(app).to_not be_called
      end

    end

  end

end

