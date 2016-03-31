require 'test_helper'




class ThreadsPad2Test < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  def setup

    ThreadsPad::JobReflection.destroy_all
    ThreadsPad::JobReflectionLog.destroy_all
    #puts "JR count =#{ThreadsPad::JobReflection.count}"
  end
  def teardown
      
      #puts "start teardown"
      ThreadsPad::Pad.terminate
      ThreadsPad::Pad.destroy_all
      ThreadsPad::Pad.wait_all
  	#ThreadsPad::JobReflectionLog.destroy_all
      #puts "finish teardown"
  end
  test "saving inside job" do 
    pad = ThreadsPad::Pad.new
    pad << TestWork.new(0, 333, true)
    pad << TestWork.new(0, 333, true)
    pad << TestWork.new(0, 334, true)
    pad.start
    sleep 0.5
    pad.wait
    assert_equal 1000, ThreadsPad::JobReflectionLog.count
  end
  test "saving inside job and on finish event" do 
    pad = ThreadsPad::Pad.new
    pad << TestWork.new(0, 333, true)
    pad << TestWork.new(0, 333, true)
    pad << TestWork.new(0, 334, true)
    on_finish = false
    amount = 0
    pad.on :finish do
      on_finish = true 
      amount = ThreadsPad::JobReflectionLog.count  
    end
    pad.start

    sleep 0.5
    pad.wait
    assert on_finish
    assert_equal 1000, ThreadsPad::JobReflectionLog.count
    assert_equal 1000, amount
    
  end
end