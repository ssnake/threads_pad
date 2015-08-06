require 'test_helper'
require 'generators/threads_pad/threads_pad_generator'

class ThreadsPadGeneratorTest < Rails::Generators::TestCase
  tests ThreadsPadGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
