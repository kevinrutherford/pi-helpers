# Copyright (C) 2018 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'rspec/expectations'

module Pi
  module Test
    module EventMatchers
      extend RSpec::Matchers::DSL

      matcher :an_event_with_type do |expected_type|
        match do |actual_event|
          actual_event.type == expected_type
        end
      end

      matcher :an_event_with_data do |expected_body|
        match do |actual_event|
          expected_body.each.all? {|k,v| actual_event.data[k] == v}
        end
      end

    end
  end
end

