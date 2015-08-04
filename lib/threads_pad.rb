require 'threads_pad/save_adapter'
module ThreadsPad
	class Pad
		
		class << self
			@@job_reflection_class = JobReflection
			def << job
				@@job_reflection_class.new job
			end
			def wait
				@job_list.each {|j| j.wait }
			end
		end
		
		
	end

	class Job
		def job_reflection= value
			@job_reflection = value
		end
		def start

			@thread = Thread.new(&(proc{self.wrapper}))
		end
		def wrapper
			@job_reflection.before_work self
			work
			@job_reflection.after_work self
		end
		def work
		end
		def wait
			@thread.join
		end
	end
end
