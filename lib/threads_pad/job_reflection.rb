module ThreadsPad
	class JobReflection < ActiveRecord::Base
		self.table_name = "threads_pad_jobs"
		def initialize job
			job.job_reflection = self
			super()

		end
		def before_work job
		end
		def after_work job
			puts "work done: #{self.result}"
		end

	end
end