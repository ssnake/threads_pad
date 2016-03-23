require 'test_helper'



class ThreadsPadTest < ActiveSupport::TestCase
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
  
  test "truth" do
    assert_kind_of Module, ThreadsPad
  end
  test "workflow" do
    # skip
    ThreadsPad::Pad<< TestWork.new(0, 5)
    assert_equal 1, ThreadsPad::JobReflection.all.count
    ThreadsPad::Pad.wait

    assert_equal 5, ThreadsPad::JobReflection.all[0].result.to_i
  end
  test "parallelism" do
  	# skip
  	pad = ThreadsPad::Pad.new
  	pad << TestWork.new(0, 5)
  	pad << TestWork.new(5, 5)
  	pad << TestWork.new(10, 5)
  	id = pad.start

  	assert id != nil
  end
  test "parallelism2" do
 	# skip
  	count = 5000
  	pad = ThreadsPad::Pad.new
  	pad << TestWork.new(0, count)
  	pad << TestWork.new(5, count)
  	pad << TestWork.new(10, count)
  	id = pad.start
  	sleep 0.1
      new_pad = ThreadsPad::Pad.new id
  	assert new_pad.current > 0.0
  	new_pad.wait
  	assert_equal 100, new_pad.current, ThreadsPad::JobReflection.all.inspect
  	assert_equal true, new_pad.done?
  end
  test "destroy_all" do
  	# skip
  	pad = ThreadsPad::Pad.new
  	pad << TestWork.new(0, 100)
  	pad.wait
  	assert_equal 1, ThreadsPad::JobReflection.all.count
  	pad.destroy_all
  	assert_equal 0, ThreadsPad::JobReflection.all.count
    ThreadsPad::Pad << TestWork.new(0, 5000)
    assert_equal 1, ThreadsPad::JobReflection.all.count
    sleep 0.5
    ThreadsPad::Pad.wait
    ThreadsPad::Pad.destroy_all
    assert_equal 0, ThreadsPad::JobReflection.all.count,  ThreadsPad::JobReflection.all.inspect
  end
  test "delete on finish" do
      # skip	
  	pad = ThreadsPad::Pad.new destroy_on_finish: true
  	pad << TestWork.new(0, 100)
  	pad.start
  	pad.wait
  	sleep 1
  	assert_equal 0, ThreadsPad::JobReflection.all.reload.count
  end
  test "no job for id" do
  	# skip
  	pad = ThreadsPad::Pad.new 123
  	assert_equal true,  pad.empty?
  end
  test "terminated" do
  	# skip
  	pad = ThreadsPad::Pad.new destroy_on_finish: true
  	pad << TestWork.new(0, 9999999)
  	pad.start
  	sleep 0.5
  	pad.terminate
  	pad.wait
  	assert_equal 0, ThreadsPad::JobReflection.all.reload.count
  end
  test "logs" do
      # skip
  	assert ThreadsPad::JobReflection.all.reload.count == 0
  	assert ThreadsPad::JobReflectionLog.all.reload.count == 0
  	ThreadsPad::Pad << TestWork.new(0, 100, true)	
  	ThreadsPad::Pad.wait
  	assert ThreadsPad::JobReflection.all.reload.count > 0
  	assert ThreadsPad::JobReflectionLog.all.reload.count > 0
  	ThreadsPad::Pad.destroy_all
  	assert ThreadsPad::JobReflection.all.reload.count == 0, ThreadsPad::JobReflection.all.reload.inspect
  	assert ThreadsPad::JobReflectionLog.all.reload.count == 0
  end
  test "logs2" do
      # skip
  	pad = ThreadsPad::Pad.new 
  	pad << TestWork.new(0, 100, true)
  	pad.start
  	pad.wait
  	assert pad.logs.count > 0, ThreadsPad::JobReflectionLog.all
  	assert pad.logs.first.created_at != nil
  end
  test "sequence" do
      # skip
  	pad = ThreadsPad::Pad.new
      pad << TestWork.new(0, 100000)
      grp_id =pad.start
      pad2 = ThreadsPad::Pad.new
      pad2 << TestWork.new(0, 100)
  	assert_not_equal grp_id, pad2.start
  end
  test 'destroy if thread is not alive' do
    # skip
    assert_equal 0, ThreadsPad::JobReflection.all.reload.count
    j = ThreadsPad::JobReflection.new nil
    j.started = true
    j.save
    ThreadsPad::Pad.destroy_all
    assert_equal 0, ThreadsPad::JobReflection.all.reload.count
  end
  test 'done' do
    assert_equal 0, ThreadsPad::JobReflection.all.reload.count
    assert ThreadsPad::Pad.done?
  end
  test 'empty' do
    assert_equal 0, ThreadsPad::JobReflection.all.reload.count
    assert ThreadsPad::Pad.empty?
  end
  test 'logs3' do
      pad = ThreadsPad::Pad.new
      pad.start
      pad.log 'test'
      assert_equal 1, pad.logs.count
  end
  test 'log4' do
    ThreadsPad::JobReflectionLog.create({id: 1, group_id: 1, job_reflection_id: 1, level: 100, msg: "1-1" })
    pad = ThreadsPad::Pad.new 1
    assert_equal 1, pad.logs.count
  end
  test 'start with old jr' do
    jr = ThreadsPad::JobReflection.new nil
    jr.id = 1
    jr.done = true
    jr.started = true
    jr.group_id = 1
    jr.save!
    pad = ThreadsPad::Pad.new 1
    assert !pad.empty?
    pad << TestWork.new(0, 1)
    pad.start
    assert_equal 1, ThreadsPad::JobReflection.all.reload.count
  end
end
