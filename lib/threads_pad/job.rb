module ThreadsPad
	class Job
		attr_accessor :pad
		

		def job_reflection= value
			@job_reflection = value
		end
		def start
			thread = Thread.new(&(proc{self.wrapper}))
			thread[:job] = self
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
			check_events
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
		
		def add_event cond, block
			@events = [] if @events.nil?
			@events << [cond, block]
		end


		def wrapper
			#ActiveRecord::Base.forbid_implicit_checkout_for_thread!
			ActiveRecord::Base.connection_pool.with_connection do 
				begin
					
					@current = 0.0
					@job_reflection.done = false
					@job_reflection.terminated = false
					@job_reflection.started = true
					@job_reflection.thread_id = Thread.current.object_id.to_s
					@job_reflection.save!
					
				
					@job_reflection.result = work
					unless @events.blank?
						while !@pad.done? except: @job_reflection
							
							Thread.pass
							check_events
						end
					end
				rescue => e
					puts "ThreadsPad::Job#wrapper: #{e.message}"
					e.backtrace.each {|msg| puts msg}
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
	private
		def check_events
			return if @events.nil? || @pad.nil?
			@events.each do |event|
				cond = event.first
				block = event.last
				#puts "check events"
				#puts "cond #{cond.class.name}"
				calc_current = @pad.calc_current
				# puts "calc_current #{calc_current}"
				# byebug if calc_current == 100
				if cond.is_a?(Range) && cond.include?(calc_current) ||
					cond.is_a?(Fixnum) && (cond == calc_current)
					block.call self
					@events.delete event
				
				end
			end
		end
				
	end
end