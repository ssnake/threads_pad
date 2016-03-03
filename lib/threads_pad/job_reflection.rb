module ThreadsPad
	class JobReflection < ActiveRecord::Base	
		self.table_name = "threads_pad_jobs"
		has_many :job_reflection_logs, dependent: :destroy

		def initialize job, **options
			@job = job
			@current_iteration = 0
			if options[:iteration_sync]
				@iteration_sync = options[:iteration_sync].to_i
			else
				@iteration_sync = 100
			end

			@job.job_reflection = self if @job.present?
			super()
			init_attributes

		end
		def init_attributes
			self.current = 0
			self.max = 100
			self.min = 0
			self.started = false
			self.destroy_on_finish = false
			self.save!			
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
		def reload_if_needed
			@current_iteration += 1
			if @current_iteration > @iteration_sync
				@current_iteration = 0
				reload
			end		
		end
		def thread_alive?
			ret = false
			Thread.list.each do |t|
				ret = true if t.object_id.to_s == self.thread_id

			end
			ret

		end

	end
end