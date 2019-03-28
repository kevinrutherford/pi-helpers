# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/util/dependent_subscriber'

RSpec.describe Pi::Util::DependentSubscriber do
  let(:piggy) { double('Eventstore subscriber') }
  let(:options) {
    {
      test_subscriber: piggy,
      upstream: {
        host: random_word,
        path: random_word,
        grace_period: random_int,
        interval: random_int
      },
      listener: double
    }
  }
  subject { Pi::Util::DependentSubscriber.new(options) }
  let(:state) { random_word }

  before do
    allow(piggy).to receive(:state).and_return(state)
    allow(piggy).to receive(:status).and_return(200)
  end

  context 'before subscribing has begun' do

    specify 'we are waiting to begin' do
      expect(subject.info[:status_code]).to eq(503)
    end

    specify "the subscriber's state is not set" do
      expect(subject.info[:state]).to eq(nil)
    end
  end

  context 'when the upstream service cannot be reached'

end

