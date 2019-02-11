# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/rack/no_content'

RSpec.describe Pi::Rack::NoContent do
  subject { Pi::Rack::NoContent.new }
  let(:response) { subject.call({}) }

  specify 'a 204 response is returned' do
    expect(response.status).to eq(204)
  end

  specify 'the response has no content' do
    expect(response.body).to be_empty
  end

end

