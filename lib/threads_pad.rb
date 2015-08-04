require 'threads_pad/save_adapter'
module ThreadsPad
	class Pad
		attr_accessor :job_list

		def initialize 
			@job_list = []

		end
		def << job
			@job_list << job
			job.save_adapter = LogSaveAdapter.new
			job.start

		end
		def wait
			@job_list.each {|j| j.wait }
		end
	end

	class Job
		def save_adapter= value
			@save_adapter = value
		end
		def start

			@thread = Thread.new(&(proc{self.wrapper}))
		end
		def wrapper
			@save_adapter.before_work self
			work
			@save_adapter.after_work self
		end
		def work
		end
		def wait
			@thread.join
		end
	end
end
