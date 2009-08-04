# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


require 'rubygems'
require 'spec'

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib sqrbl]))

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end


# Stub out the various things that the migration writers do.
# Call this after defining the mocks you care about (because mocks created first take precedence).
# Then, calling #write! shouldn't actually touch the filesystem.
def stub_out_file_creation
  File     .should_receive(:directory?).with(any_args).any_number_of_times.and_return(true)
  FileUtils.should_receive(:makedirs)  .with(any_args).any_number_of_times
  File     .should_receive(:open)      .with(any_args).any_number_of_times.and_return(mock('File'))
end

# EOF
