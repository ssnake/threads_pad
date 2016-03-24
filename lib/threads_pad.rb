require 'threads_pad/job_reflection_log'
require 'threads_pad/job_reflection'
require 'threads_pad/job'
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
			job.pad = self
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
				jr.destroy if job_reflection_old?(jr)
			end
			
		end
		def current
			ThreadsPad::Pad.current @list
			
		end
		def done? **options
			if options.key? :except
				list = @list
				list.delete options[:except]
				ThreadsPad::Pad.done? list
			else
				ThreadsPad::Pad.done? @list
			end
		end
		def terminate
			ThreadsPad::Pad.terminate @list
		end
		def logs
			return [] if @grp_id.nil?
			JobReflectionLog.where('group_id = ?', @grp_id)
		end
		def log msg, level=0
			return if @grp_id.nil?
			JobReflectionLog.create! group_id: @grp_id, msg: msg, level: level

		end
		def on cond, &block
			@list.each do |jr| 
			  	if !job_reflection_old?(jr)
					jr.job.add_event cond, block
					return
				end
			end
		end
		def calc_current
			return nil if @list.nil?
			list = @list.map {|jr| jr.job}
			ThreadsPad::Pad.calc_current list
		end
		class << self

			def << job
				refl = JobReflection.new job
				
				job.start
				return refl
				puts "JR count #{JobReflection.count}"

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
				calc_current list
				
			end
			def calc_current list
				return nil if list.nil?
				res = 0
				list.each do |jr|
					res += (jr.current.to_f-jr.min)/(jr.max-jr.min) * 100.0 / list.count
				end
				res.round
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
		def job_reflection_old? jr
			jr.started && jr.done && !jr.thread_alive?
		end
		def get_group_id
			#(JobReflection.maximum("group_id") || 0) + 1
			id = -1
			begin
				id = Random.rand(0..2**31)
			end until JobReflection.where(group_id: id).length == 0
			id
			
		end		
		
	end
end

ActiveSupport.on_load(:action_view) do
  include ThreadsPad::Helper
end