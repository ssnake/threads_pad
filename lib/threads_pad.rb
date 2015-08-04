require 'threads_pad/job_reflection'
module ThreadsPad
	class Pad
		
		class << self

			def << job
				refl = JobReflection.new job
				refl.save!
				job.start
			end
			def wait
				sleep 1
			end
			def list
				JobReflection.all
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
			#ActiveRecord::Base.forbid_implicit_checkout_for_thread!

			ActiveRecord::Base.connection_pool.with_connection do 
				@job_reflection.done = false
				@job_reflection.terminated = false
				@job_reflection.before_work self
				@job_reflection.result = work
				@job_reflection.after_work self
				@job_reflection.done = true
				@job_reflection.save!
			end
			ActiveRecord::Base.connection.close
		end
		def work
		end
		def wait
			@thread.join
		end
		def set_max_progress value
			@job_reflection.set_max_progress value
		end
		def set_current_progress value
			@job_reflection.set_current_progress value
		end
		def terminated?
			@job_reflection.reload
			@job_reflection.terminated
		end
	end
end
