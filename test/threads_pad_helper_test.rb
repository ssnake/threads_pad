require 'test_helper'

class ThreadsPadHelperTest < ActiveSupport::TestCase
  attr_accessor :session
  include ThreadsPad::Helper
  
  def setup
  	ThreadsPad::JobReflectionLog.create({id: 1, group_id: 1, job_reflection_id: 1, level: 100, msg: "1-1" })
  	ThreadsPad::JobReflectionLog.create({id: 2, group_id: 1, job_reflection_id: 1, level: 100, msg: "1-2" })
  	ThreadsPad::JobReflectionLog.create({id: 3, group_id: 1, job_reflection_id: 1, level: 100, msg: "1-3" })
  	ThreadsPad::JobReflectionLog.create({id: 4, group_id: 1, job_reflection_id: 1, level: 100, msg: "1-4" })
  	ThreadsPad::JobReflectionLog.create({id: 5, group_id: 1, job_reflection_id: 1, level: 100, msg: "1-5" })
  	@session = {}

  end

  def teardown
  end

  test "truth" do
  	filter_job_logs nil
  	assert   ThreadsPad::JobReflectionLog.count > 0
  end

  test 'filter_job_logs' do
  	list = ThreadsPad::JobReflectionLog.all[0],  ThreadsPad::JobReflectionLog.all[1]

  	assert_equal 2, filter_job_logs(list).length
  	assert_equal 3, filter_job_logs(ThreadsPad::JobReflectionLog.all).count
  	assert_equal 0, filter_job_logs(ThreadsPad::JobReflectionLog.all).count


  end
  test 'filter_job_logs_diff_job_refl' do
  	l21 = ThreadsPad::JobReflectionLog.create({id: 6, group_id: 2, job_reflection_id: 2, level: 100, msg: "2-1" })
  	l22 = ThreadsPad::JobReflectionLog.create({id: 7, group_id: 2, job_reflection_id: 2, level: 100, msg: "2-2" })

  	l23 = ThreadsPad::JobReflectionLog.create({id: 8, group_id: 2, job_reflection_id: 2, level: 100, msg: "2-3" })

  	list2 = [l21, l22]
  	list = ThreadsPad::JobReflectionLog.all[0],  ThreadsPad::JobReflectionLog.all[1]

  	assert_equal 2, filter_job_logs(list2).length
  	assert_equal 2, filter_job_logs(list).length
  	list2 << l23
  	assert_equal 1, filter_job_logs(list2).count
  	assert_equal 3, filter_job_logs(ThreadsPad::JobReflectionLog.all).count
  	assert_equal 0, filter_job_logs(ThreadsPad::JobReflectionLog.all).count


  end
  test 'symbolization' do
  	assert_equal 1, filter_job_logs(["job_reflection_id": 3, 'id': 1, group_id: 1]).length
  	assert_equal 1, filter_job_logs([{job_reflection_id: 3, 'id': 1, group_id: 1}, {"job_reflection_id": 3, 'id': 2, group_id: 1}]).length
  	assert_equal 0, filter_job_logs([{'job_reflection_id': 3, 'id': 1, group_id: 1}, {job_reflection_id: 3, 'id': 2, group_id: 1}]).length
  	puts session.inspect

  end
  test 'general log' do
    assert_equal 5, filter_job_logs(ThreadsPad::JobReflectionLog.all).count
    ThreadsPad::JobReflectionLog.create({id: 6, group_id: 1, job_reflection_id: nil, level: 100, msg: "1-0" })
    assert_equal 1, filter_job_logs(ThreadsPad::JobReflectionLog.all).count
    ThreadsPad::Pad.destroy_all
    assert_equal 0, (ThreadsPad::JobReflectionLog.all).count
  end
end