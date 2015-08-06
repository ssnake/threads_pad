require 'test_helper'

class TestWork < ThreadsPad::Job
	def initialize start, count
		@start = start
		@count = count
	end

	def work 
		sum= @start
		self.max = @count
		@count.times do 
			#puts sum
			sum += 1
			self.current+=1
		end
		return sum
	end
end

class ThreadsPadTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  def setup
  	ThreadsPad::JobReflection.destroy_all
  end
  
  test "truth" do
    assert_kind_of Module, ThreadsPad
  end
  test "workflow" do
    ThreadsPad::Pad<< TestWork.new(0, 5)
    assert_equal 1, ThreadsPad::JobReflection.all.count
    ThreadsPad::Pad.wait

    assert_equal 5, ThreadsPad::JobReflection.all[0].result.to_i
  end
  test "parallelism" do
  	#skip
  	pad = ThreadsPad::Pad.new
  	pad << TestWork.new(0, 5)
  	pad << TestWork.new(5, 5)
  	pad << TestWork.new(10, 5)
  	id = pad.start

  	assert id != nil
  end
  test "parallelism2" do
 	#skip
  	count = 5000
  	pad = ThreadsPad::Pad.new
  	pad << TestWork.new(0, count)
  	pad << TestWork.new(5, count)
  	pad << TestWork.new(10, count)
  	id = pad.start
  	new_pad = ThreadsPad::Pad.new id
  	new_pad.wait
  	assert_equal 100, new_pad.current# ThreadsPad::JobReflection.all.inspect

  end
end
