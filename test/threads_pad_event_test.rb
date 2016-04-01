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

  # test 'event' do
  #   ThreadsPad::Pad<< TestWork.new(0, 500000)
  #   sleep 0.5
  #   assert !ThreadsPad::Pad.done?, ThreadsPad::JobReflection.all.inspect
  # end
  # test 'event2' do
  #   pad = ThreadsPad::Pad.new
  #   pad << TestWork.new(0, 500)
  #   id = pad.start
  #   sleep 0.5 
  #   pad.wait
    
  #   pad = ThreadsPad::Pad.new id

  #   pad << TestWork.new(0, 500)
    
  #   ecount = 0
  #   pad.on(5) { ecount +=1}
  #   pad.on(15) { ecount +=1}
  #   pad.on(100) { ecount +=1}
  #   pad.start
  #   sleep 0.5
  #   pad.wait
  #   assert_equal 3, ecount
  # end
  # test 'event1' do
  #   assert_equal 0, ThreadsPad::JobReflection.count
  #   pad = ThreadsPad::Pad.new
  #   pad << TestWork.new(0, 500)
  #   pad << TestWork.new(0, 50000)
  #   #closure variable
  #   event_count = 0
    
    
  #   pad.on(20..50) do |job|
  #     puts "20..50 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
      
  #   end
  #   pad.on(50..75) do 
  #     puts "50..75 "
  #     event_count += 1
      
  #   end
  #   event_count = 0
  #   pad.on(75..100) do  |job|
  #     puts "75..100 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      
  #     event_count += 1
      
  #   end
  #   pad.on(0..5) do |job|
  #     puts "0..5 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
      
  #   end
  #   pad.on(6..10) do |job|
  #     puts "6..10 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
      
  #   end
  #   pad.on(10..20) do |job|
  #     puts "10..20 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
      
  #   end
  #   pad.on(100) do |job|
  #     puts "100 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
      
  #   end
    
  #   pad.on(:finish) do |job|
  #     puts "finish #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
  #   end
  #   pad.on(200) do |job|
  #     puts "this should never happen job.current #{job.current}, pad.calc_current #{pad.calc_current}"
  #     event_count += 1
      
  #   end
  #   pad.start
  #   sleep 1
  #   pad.wait

  #   assert pad.done?
   
  #   assert_equal 8, event_count

  # end
  # test 'wait' do
  #   pad = ThreadsPad::Pad.new
  #   pad << TestWork.new(0, 500)
  #   pad << TestWork.new(0, 5000)
  #   pad << TestWork.new(0, 50000)
    
    
  #   pad.start
  #   sleep 0.5
  #   pad.wait
  #   assert pad.done?
  #   sleep 0.5
  #   assert_equal 55500, JobReflection.sum(:current)
  # end
  test 'on finish' do
     pad = ThreadsPad::Pad.new
     pad << TestWork.new(0, 500)
     pad << TestWork.new(0, 5000)
     pad << TestWork.new(0, 50000)
     on_finish = false
     amount = 0
     pad.on :finish do
         on_finish = true
         # sleep 0.5
         amount = JobReflection.sum(:current)
         puts "amount: #{amount}"
     end
    pad.start
    sleep 1.5
    pad.wait
    assert on_finish
    assert_equal 55500, amount
    assert_equal 55500, JobReflection.sum(:current)
  end
end 