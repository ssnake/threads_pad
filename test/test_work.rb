class TestWork < ThreadsPad::Job
	def initialize start, count, use_logs=false
		@start = start
		@count = count
		@use_logs = use_logs
	end

	def work 
		#puts "started worker"
		sum= @start
		self.max = @count
		@count.times do 
			sum += 1
			self.current+=1
			debug "current #{self.current}" if @use_logs
			if terminated?
				puts "terminated"
				break
			end
		end
		return sum
	end
end