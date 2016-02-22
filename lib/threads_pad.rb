require 'threads_pad/job_reflection_log'
require 'threads_pad/job_reflection'

module ThreadsPad
	class Pad
		
		def initialize id=nil, **options
			@options = options || {}
			@list = []
			if id 
				@group_id = id
				@list = JobReflection.where('group_id = ?', id)

			end
		end
		
		def << job
			refl = JobReflection.new job, @options
			if @options[:destroy_on_finish]
				refl.destroy_on_finish = true
				refl.save!
			end
			@list << refl
		end
		def empty?
			@list.count == 0
		end
		def start
			grp_id = get_group_id 
			@list.each do |jr|
				jr.group_id = grp_id
				jr.started = true
				jr.save
				jr.start
			end
			grp_id
		end
		def wait
			ThreadsPad::Pad.wait @list
		end
		def destroy_all
			ThreadsPad::Pad.destroy_all @list
		end
		def current
			ThreadsPad::Pad.current @list
			
		end
		def done?
			ThreadsPad::Pad.done? @list
		end
		def terminate
			ThreadsPad::Pad.terminate @list
		end
		def logs
			ret = []
			@list.each do |jr|
				jr.job_reflection_logs.each { |l| ret << l}
			end
			ret
		end

		class << self

			def << job
				refl = JobReflection.new job
				job.start
				return refl
			end
			def destroy_all list=nil
				list = JobReflection.all if list.nil?
				list.each do |jr|
					jr.destroy if jr.done || !jr.started
					if jr.started && !jr.done
						jr.destroy_on_finish = true 
						jr.save!
					end
				end
			end
			def wait list=nil
				sleep 0.1
				running = true
				list = JobReflection.all if list.nil?
				while running do
					running = false
					list.each do |jr|
						begin
							jr.reload
							running = running || !jr.done && jr.started && !jr.destroy_on_finish
						rescue ActiveRecord::RecordNotFound
						end
					end
					#puts "waiting: #{list.inspect}"
					sleep 0.3
				end
			end
			def current list=nil
				list = JobReflection.all if list.nil?
				res = 0

				list.each do |jr|
					res += (jr.current.to_f-jr.min)/(jr.max-jr.min) * 100.0 / list.count
				end
				res
			end
			def done? list =nil
				list = JobReflection.all if list.nil?
				res = false
				list.each do |jr|
					res ||= jr.done
				end
				res
			end
			def terminate list=nil
				list = JobReflection.all if list.nil?
				list.each do |jr|
					jr.terminated = true
					jr.save!
				end
			end
		end
	private
		def get_group_id
			(JobReflection.maximum("group_id") || 0) + 1
			
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
				@current = 0.0
				@job_reflection.done = false
				@job_reflection.terminated = false
				@job_reflection.started = true
				@job_reflection.save!
				begin
					@job_reflection.result = work
				rescue => e
					puts e.message
				ensure
					@job_reflection.done = true
					if @job_reflection.destroy_on_finish
						@job_reflection.destroy
					else
						
						@job_reflection.save!
					end
				end
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
			@current = value
			return if @job_reflection.nil?
			@job_reflection.current = @current
			@job_reflection.save_if_needed
		end
		def current 
			@current
		end

		def terminated?
			return false if @job_reflection.nil?
			@job_reflection.reload_if_needed
			@job_reflection.terminated
		end
		def debug msg
			@job_reflection.job_reflection_logs.create(level: 0, msg: msg) if @job_reflection
		rescue => e
			puts "debug: #{e.message}"
		end
	end
end
