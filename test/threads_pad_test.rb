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
  test "truth" do
    assert_kind_of Module, ThreadsPad
  end
  test "workflow" do
    ThreadsPad::Pad<< TestWork.new
    ThreadsPad::Pad.wait
    assert_equal 5, ThreadsPad::Pad.job_list[0].res
  end
end
