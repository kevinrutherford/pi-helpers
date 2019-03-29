# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/eventstore/subscriber'

RSpec.describe Pi::Eventstore::Subscriber do
  let(:logger) { double('Logger', call: true) }
  let(:info) { { status_code: 200 } }
  let(:options) {
    {
      url: random_word,
      username: random_word,
      password: random_word,
      reducer: double
    }
  }
  subject { Pi::Eventstore::Subscriber.new(info, options, logger) }
  let(:base_etag) { random_word }

  describe '#subscribe' do
    let(:stream) { double('Stream') }

    before do
      allow(Pi::Eventstore::Stream).to receive(:open).and_return(stream)
    end

    specify 'display busy while replaying history' do
      statuses = []
      allow(stream).to receive(:wait_for_new_events) { statuses << info[:status_code] }
      allow(stream).to receive(:each_event) {
        statuses << info[:status_code]
        raise 'boom' if statuses.length >= 6
      }
      expect { subject.subscribe }.to raise_error(RuntimeError)
      expect(statuses).to eq([503, 503, 200, 503, 200, 503])
    end

  end
end

