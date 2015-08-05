require 'threads_pad/job_reflection'
module ThreadsPad
	class Pad
		
		def initialize id=nil
			@list = []
			if id 
				@group_id = id
				@list = JobReflection.where('group_id = ?', id)
			end
		end
		
		def << job
			refl = JobReflection.new job
			refl.current = 0
			refl.max = 100
			refl.min = 0
			refl.save!
			@list << refl
		end
		def start
			grp_id = get_group_id 
			@list.each do |jr|
				jr.group_id = grp_id
				jr.save
				jr.start
			end
			grp_id
		end
		def wait
			running = true
			while running do
				running = false
				@list.each do |jr|
					jr.reload
					running = running || !jr.done

				end
				sleep 0.3
			end
		end
		def current
			res = 0
			@list.each do |jr|
				res += (jr.current-jr.min)/(jr.max-jr.min) / @list.count
			end
			res

		end

		class << self

			def << job
				refl = JobReflection.new job
				refl.save!
				job.start
				return refl
			end
			def wait
				sleep 1
			end
			def list
				JobReflection.all
			end
		end
	private
		def get_group_id
			JobReflection.maximum("group_id") || 0 + 1
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
			ActiveRecord::Base.forbid_implicit_checkout_for_thread!

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
		def min=value
			@job_reflection.min = value
			@job_reflection.save!
		end
		def min
			@job_reflection.min
		end
		def max 
			@job_reflection.max
		end
		def max=value
			@job_reflection.max = value
			@job_reflection.save!
		end
		def current=value
			@job_reflection.current = value
			@job_reflection.save_if_needed
		end
		def current 
			@job_reflection.current
		end

		def terminated?
			@job_reflection.reload
			@job_reflection.terminated
		end
	end
end
