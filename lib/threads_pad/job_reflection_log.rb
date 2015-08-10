module ThreadsPad
	class JobReflectionLog < ActiveRecord::Base
		self.table_name = "threads_pad_job_logs"
		belongs_to :job_reflection
	end
end