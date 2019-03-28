# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/util/dependent_subscriber'

RSpec.describe Pi::Util::DependentSubscriber do
  let(:logger) { double('Logger', call: true) }
  let(:es_subscriber) { double('Eventstore subscriber') }
  subject { Pi::Util::DependentSubscriber.new(options) }
  let(:state) { random_word }

  before do
    allow(es_subscriber).to receive(:subscribe)
    allow(es_subscriber).to receive(:state).and_return(state)
    allow(es_subscriber).to receive(:status).and_return(200)
  end

  context 'before subscribing has begun' do
    let(:options) {
      {
        test_subscriber: es_subscriber,
        upstream: {
          host: random_word,
          path: random_word,
          grace_period: random_int,
          interval: random_int
        },
        listener: logger
      }
    }

    specify 'we are waiting to begin' do
      expect(subject.info[:status_code]).to eq(503)
    end

    specify "the subscriber's state is not set" do
      expect(subject.info[:state]).to eq(nil)
    end
  end

  context 'when there is no upstream' do
    let(:options) {
      {
        test_subscriber: es_subscriber,
        listener: logger
      }
    }

    before do
      subject.start
    end

    specify 'our status is switched to 200' do
      expect(subject.info[:status_code]).to eq(200)
    end

    specify 'the subscriber is started' do
      expect(es_subscriber).to have_received(:subscribe)
    end
  end

  context 'when there is an upstream' do
    let(:options) {
      {
        test_subscriber: es_subscriber,
        upstream: {
          host: random_word,
          path: random_word,
          grace_period: 0,
          interval: 0
        },
        listener: logger
      }
    }
    let(:upstream) { double('Upstream') }

    before do
      allow(upstream).to receive(:check).and_return(*upstream_responses)
      allow(Pi::Util::Upstream).to receive(:new).and_return(upstream)
      subject.start
    end

    context 'but the upstream service cannot be reached' do
      let(:upstream_responses) { [
        { status_code: 503, message: "I'm busy" },
        { status_code: 503, message: "I'm busy" },
        { status_code: 502, message: "I'm dead" }
      ] }

      specify 'the subscriber is not started' do
        expect(es_subscriber).to_not have_received(:subscribe)
      end

      specify 'our status shows the problem' do
        expect(subject.info[:status_code]).to eq(502)
        expect(subject.info[:message]).to eq("I'm dead")
      end
    end

    context 'and the upstream is eventually ok' do
      let(:upstream_responses) { [
        { status_code: 503, message: "I'm busy" },
        { status_code: 503, message: "I'm busy" },
        { status_code: 200, message: "OK" }
      ] }

      specify 'the subscriber is started' do
        expect(es_subscriber).to have_received(:subscribe)
      end

      specify 'our status shows everything is working' do
        expect(subject.info[:status_code]).to eq(200)
        expect(subject.info[:message]).to eq("OK")
      end
    end

  end

end

