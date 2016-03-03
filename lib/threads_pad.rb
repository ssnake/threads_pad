require 'threads_pad/job_reflection_log'
require 'threads_pad/job_reflection'
require 'threads_pad/helper'

module ThreadsPad
	class Pad
		
		def initialize id=nil, **options
			@options = options || {}
			@list = []
			@grp_id = id
			if id 
				@group_id = id
				@list = JobReflection.where('group_id = ?', id).to_a

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
			@grp_id = get_group_id 
			destroy_old
			@list.each do |jr|
				jr.group_id = @grp_id
				jr.started = true
				jr.save!
				jr.start
			end
			@grp_id
		end
		def wait
			ThreadsPad::Pad.wait @list
		end
		def destroy_all
			ThreadsPad::Pad.destroy_all @list
		end
		def destroy_old
			@list.delete_if do |jr|
				jr.destroy if jr.started && jr.done && !jr.thread_alive?
			end
			
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
			raise 'Group id is not defined' if @grp_id.nil?
			JobReflectionLog.where('group_id = ?', @grp_id)
		end
		def log msg, level=0
			raise 'Group id is not defined' if @grp_id.nil?
			JobReflectionLog.create! group_id: @grp_id, msg: msg, level: level

		end
		class << self

			def << job
				refl = JobReflection.new job
				job.start
				return refl
			end
			def destroy_all list=nil
				JobReflectionLog.destroy_all  if list.nil?
				list = JobReflection.all if list.nil?
				list.each do |jr|
					if jr.started && !jr.done && jr.thread_alive?
						jr.destroy_on_finish = true 
						jr.save!
					else
						jr.destroy #if jr.done #|| !jr.started
					end
				end

			end
			def wait list=nil, wait_for_destroy_on_finish=false
				sleep 0.1 # needed to be sure other threads are started
				running = true
				list = JobReflection.all if list.nil?
				while running do
					running = false
					list.each do |jr|
						begin
							jr.reload
							running = running || jr.thread_alive? && !jr.done && jr.started && (wait_for_destroy_on_finish || !jr.destroy_on_finish)
						rescue ActiveRecord::RecordNotFound
						end
					end
					#puts "waiting: #{list.inspect}"

					sleep 0.3
				end

			end
			def wait_all list=nil
				self.wait list, true
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
				res = true
				list.each do |jr|
					res &&= jr.done || !jr.thread_alive?
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
			def  empty?
				JobReflection.count == 0
			end
		end
	private
		def get_group_id
			#(JobReflection.maximum("group_id") || 0) + 1
			id = -1
			begin
				id = Random.rand(0..2**31)
			end until JobReflection.where(group_id: id).length == 0
			id
			
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
				begin
					@current = 0.0
					@job_reflection.done = false
					@job_reflection.terminated = false
					@job_reflection.started = true
					@job_reflection.thread_id = @thread.object_id.to_s
					@job_reflection.save!

				
					@job_reflection.result = work
				rescue => e
					puts "ThreadsPad::Job#wrapper: #{e.message} #{e.backtrace.inspect}"
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
			@job_reflection.job_reflection_logs.create(level: 0, msg: msg, group_id: @job_reflection.group_id) if @job_reflection
		rescue => e
			puts "debug: #{e.message}"
		end
	end
end

ActiveSupport.on_load(:action_view) do
  include ThreadsPad::Helper
end