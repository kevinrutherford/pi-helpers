# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/eventstore/stream'

RSpec.describe Pi::Eventstore::Stream do
  let(:logger) { double('Logger', call: true) }
  let(:connection) { double('Connection') }
  let(:stream_name) { random_word }
  let(:initial_status_code) { random_int }
  let(:info) { { status_code: initial_status_code } }
  subject { Pi::Eventstore::Stream.open(stream_name, connection, info, logger) }
  let(:base_etag) { random_word }

  describe '#each_event' do

    context 'when the stream has more than one page of events' do
      let(:last_uri) { "#{stream_name}/last" }
      let(:head_page) {
        FakeResponse.new(200, {'etag' => base_etag}, {
          'links' => [{'uri' => last_uri, 'relation' => 'last'}],
          'entries' => []
        })
      }
      let(:previous_uri) { "#{random_word}/prev" }
      let(:last_page) {
        FakeResponse.new(200, {'etag' => base_etag}, {
          'links' => [{'uri' => previous_uri, 'relation' => 'previous'}],
          'entries' => [{'type' => 'boo', 'data' => '{"id": 3}'},{'type' => 'boo', 'data' => '{"id": 4}'}]
        })
      }
      let(:first_etag) { random_word }
      let(:first_page) {
        FakeResponse.new(200, {'etag' => first_etag}, {
          'links' => [{'uri' => last_uri, 'relation' => 'last'}],
          'entries' => []
        })
      }

      before do
        expect(connection).to receive(:get).with("/streams/#{stream_name}", nil).and_return(head_page)
        expect(connection).to receive(:get).with(last_uri, base_etag).and_return(last_page)
        expect(connection).to receive(:get).with(previous_uri, base_etag).and_return(first_page)
        @yielded = []
        subject.wait_for_new_events
        subject.each_event {|evt| @yielded << evt.data[:id] }
      end

      specify 'yields the entries in all pages, starting with the last' do
        expect(@yielded).to eq([4, 3])
      end

      specify 'leaves the status code unchanged' do
        expect(info[:status_code]).to eq(initial_status_code)
      end
    end

    context 'when the head of stream is also the last page' do
      let(:previous_uri) { "#{stream_name}/prev" }
      let(:previous_etag) { random_word }
      let(:head_page) {
        FakeResponse.new(200, {'etag' => base_etag}, {
          'links' => [{'uri' => previous_uri, 'relation' => 'previous'}],
          'entries' => [{'type' => 'boo', 'data' => '{"id": 1}'},{'type' => 'boo', 'data' => '{"id": 2}'}]
        })
      }
      let(:previous_page) {
        FakeResponse.new(200, {'etag' => previous_etag}, {
          'links' => [{'uri' => random_word, 'relation' => 'last'}],
          'entries' => []
        })
      }

      before do
        expect(connection).to receive(:get).with("/streams/#{stream_name}", nil).and_return(head_page)
        expect(connection).to receive(:get).with(previous_uri, base_etag).and_return(previous_page)
        @yielded = []
        subject.wait_for_new_events
        subject.each_event {|evt| @yielded << evt.data[:id] }
      end

      specify 'yields the entries from the head page in reverse order' do
        expect(@yielded).to eq([2, 1])
      end

      specify 'leaves the status code unchanged' do
        expect(info[:status_code]).to eq(initial_status_code)
      end
    end

  end
end

