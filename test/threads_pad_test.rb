require 'test_helper'

class TestWork < ThreadsPad::Job
	attr_accessor :res
	def work
		sum = 0
		5.times do 
			sum += 1
		end
		@res = sum
		return sum
	end
end

class ThreadsPadTest < ActiveSupport::TestCase
  def setup
  	ThreadsPad::JobReflection.destroy_all
  end
  self.use_transactional_fixtures = false
  test "truth" do
    assert_kind_of Module, ThreadsPad
  end
  test "workflow" do
    ThreadsPad::Pad<< TestWork.new
    ThreadsPad::Pad.wait
    assert_equal 5, ThreadsPad::JobReflection.all[0].result.to_i
  end
end
