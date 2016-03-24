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
  #   sleep 0.1   
  #   assert !ThreadsPad::Pad.done?, ThreadsPad::JobReflection.all.inspect
  # end

  test 'event1' do
    pad = ThreadsPad::Pad.new
    pad << TestWork.new(0, 500)
    pad << TestWork.new(0, 500)
    #closure variable
    event_count = 0
    
    
    pad.on(20..50) do |job|
      puts "20..50 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      event_count += 1
      
    end
    pad.on(50..75) do 
      puts "50..75 "
      event_count += 1
      
    end
    event_count = 0
    pad.on(75..100) do  |job|
      puts "75..100 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      
      event_count += 1
      
    end
    pad.on(0..5) do |job|
      puts "0..5 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      event_count += 1
      
    end
    pad.on(6..10) do |job|
      puts "6..10 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      event_count += 1
      
    end
    pad.on(10..20) do |job|
      puts "10..20 job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      event_count += 1
      
    end
    pad.on(100) do |job|
      puts "finished job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      event_count += 1
      
    end
    pad.on(200) do |job|
      puts "this should never happen job.current #{job.current}, pad.calc_current #{pad.calc_current}"
      event_count += 1
      
    end
    pad.start
    pad.wait
    assert pad.done?
    assert_equal 7, event_count

  end


end