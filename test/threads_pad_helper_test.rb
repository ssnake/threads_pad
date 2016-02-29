require 'test_helper'

class ThreadsPadHelperTest < ActiveSupport::TestCase
  attr_accessor :session
  include ThreadsPad::Helper
  
  def setup
  	ThreadsPad::JobReflectionLog.create({id: 1, job_reflection_id: 1, level: 100, msg: "1" })
  	ThreadsPad::JobReflectionLog.create({id: 2, job_reflection_id: 1, level: 100, msg: "2" })
  	ThreadsPad::JobReflectionLog.create({id: 3, job_reflection_id: 1, level: 100, msg: "3" })
  	ThreadsPad::JobReflectionLog.create({id: 4, job_reflection_id: 1, level: 100, msg: "4" })
  	ThreadsPad::JobReflectionLog.create({id: 5, job_reflection_id: 1, level: 100, msg: "5" })
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
end