# Copyright (C) 2019 Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'simplecov'
SimpleCov.start

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|

  config.disable_monkey_patching!

  config.alias_it_should_behave_like_to :it_looks_like, 'looks like:'

  config.order = :random
  Kernel.srand config.seed

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end

end

