# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/util/dependent_subscriber'

RSpec.describe Pi::Util::DependentSubscriber do
  let(:piggy) { double('Eventstore subscriber') }
  let(:options) {
    {
      subscriber: piggy,
      upstream: {},
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
      expect(subject.info[:status]).to eq(503)
    end

    specify "the subscriber's state is passed on" do
      expect(subject.info[:state]).to eq(state)
    end
  end

end

