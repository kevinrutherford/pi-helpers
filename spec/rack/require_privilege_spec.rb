# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/require_privilege'

RSpec.describe Pi::Rack::RequirePrivilege do
  let(:app) { double('App', call: nil) }
  let(:priv) { :privilege }
  subject { Pi::Rack::RequirePrivilege.new(app, priv) }
  let(:response) { subject.call(env) }

  context 'when the claims have not been unpacked' do
    let(:env) { { } }

    specify 'a 509 response is returned' do
      expect(response.status).to eq(509)
    end

    specify 'the app is not called' do
      response
      expect(app).to_not have_received(:call)
    end

  end

end

