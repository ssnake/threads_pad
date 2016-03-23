require 'test_helper'

class ThreadsPadEventTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  include ThreadsPad
  def setup
    ThreadsPad::JobReflection.destroy_all
    ThreadsPad::JobReflectionLog.destroy_all
  end

  def teardown
    ThreadsPad::Pad.terminate
    ThreadsPad::Pad.destroy_all
    ThreadsPad::Pad.wait_all
  end

  test 'event' do
    ThreadsPad::Pad<< TestWork.new(0, 500000)
    sleep 0.1   
    assert !ThreadsPad::Pad.done?, ThreadsPad::JobReflection.all.inspect
  end
  
  # test 'event1' do
  #   pad = ThreadsPad::Pad.new
  #   pad << TestWork.new(0, 500)
  #   pad.on(0..50) do 
  #   end

  # end


end