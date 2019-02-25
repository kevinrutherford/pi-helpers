# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/strip_params'

RSpec.describe Pi::Rack::StripParams do
  let(:app) { Pi::Test::AppShunt.new }
  subject { Pi::Rack::StripParams.new(app) }

  context 'when there are no router params in the environment' do
    specify 'an error is thrown' do
      expect { subject.call({}) }.to raise_error(Pi::Rack::ConfigurationError)
      expect(app).to_not be_called
    end
  end

end

