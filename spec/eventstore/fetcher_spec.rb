# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/eventstore/fetcher'

RSpec.describe Pi::Eventstore::Fetcher do
  let(:connection) { double('Connection') }
  subject { Pi::Eventstore::Fetcher.new(connection) }

  context 'when Eventstore returns errors' do

    before do
      allow(connection).to receive(:get).and_return(
        FakeResponse.new(502, {}, 'error 1'),
        FakeResponse.new(404, {}, 'error 2'),
        FakeResponse.new(200, {}, 'events payload')
      )
    end

    specify 'the status code and message are yielded for each error' do
      yielded = []
      subject.fetch(random_word, random_word, on_error: ->(code, msg) { yielded << [code, msg] })
      expect(yielded).to eq([
        [502, 'error 1'],
        [404, 'error 2']
      ])
    end

  end

  context 'when Faraday throws an exception' do

    before do
      allow(connection).to receive(:get).and_raise(Faraday::Error, 'BOOM')
    end

    specify 'a 502 error is yielded' do
      skip
      yielded = []
      subject.fetch(random_word, random_word, on_error: ->(code, msg) { yielded << [code, msg] })
      expect(yielded).to eq([
        [502, 'BOOM']
      ])
    end
  end

end

