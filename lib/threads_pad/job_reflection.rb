module ThreadsPad
	class JobReflection < ActiveRecord::Base
		self.table_name = "threads_pad_jobs"

		def initialize job
			@job = job
			@current_iteration = 0
			@iteration_sync = 1000
			job.job_reflection = self
			super()
			init_attributes

		end
		def init_attributes
			self.current = 0
			self.max = 100
			self.min = 0
			self.started = false
			self.save!			
		end
		def before_work job
		end
		def after_work job
		end
		def start
			@job.start
		end
		def save_if_needed
			@current_iteration += 1
			if @current_iteration > @iteration_sync
				@current_iteration = 0
				save!
			end

		end

	end
end