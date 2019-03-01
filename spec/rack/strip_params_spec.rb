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

  context 'when a param has space padding' do
    let(:env) {
      {
        'ignore_me' => '  padded ',
        'ignore_me_too' => 34,
        'router.params' => {
          p1: 34,
          p2: ' pad ',
          p3: [5, ' pad ', 7]
        }
      }
    }

    specify 'the padding is stripped' do
      subject.call(env)
      expect(app.env_passed['ignore_me']).to eq('  padded ')
      expect(app.env_passed[Pi::Rack::PARAMS_KEY]).to eq({
          p1: 34,
          p2: 'pad',
          p3: [5, ' pad ', 7]
      })
    end
  end

  context 'when there is a query string' do
    let(:env) {
      {
        'QUERY_STRING' => 'filter[nuttshell]=34&order=desc',
        'router.params' => {
          p2: ' pad ',
        }
      }
    }

    specify 'it is added to the params' do
      subject.call(env)
      expect(app.env_passed[Pi::Rack::PARAMS_KEY]).to eq({
          p2: 'pad',
          filter: { 'nuttshell' => '34' },
          order: 'desc'
      })
    end
  end

end

