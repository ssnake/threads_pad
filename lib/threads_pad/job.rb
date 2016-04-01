module ThreadsPad
	class Job
		attr_accessor :pad
		

		def job_reflection= value
			sync {@job_reflection = value}
		end
		def start
			thread = Thread.new(&(proc{self.wrapper}))
			thread[:job] = self
		end
		
		
		def work
		end

		def min=value
			sync do
				@job_reflection.min = value
				@job_reflection.save!
			end
		end
		def min
			@job_reflection.min
		end
		def max 
			@job_reflection.max
		end
		def max=value
			sync do
				@job_reflection.max = value
				@job_reflection.save!
			end
		end
		def current=value
			sync do
				@current = value
				check_events
				return if @job_reflection.nil?
			
				@job_reflection.current = @current
			
				@job_reflection.save_if_needed
			end
		end
		def current 
			@current
		end

		def terminated?
			sync do
				return false if @job_reflection.nil?
				@job_reflection.reload_if_needed
				@job_reflection.current = @current
				@job_reflection.terminated
			end
		end

		def debug msg
			sync {
				@job_reflection.job_reflection_logs.create(level: 0, msg: msg, group_id: @job_reflection.group_id) if @job_reflection
			}
		rescue => e
			puts "debug: #{e.message}"
		end
		
		def add_event cond, block

			@events = [] if @events.nil?
			@events << [cond, block]
		end


		def wrapper
			#ActiveRecord::Base.forbid_implicit_checkout_for_thread!
			
				
			begin
				sync do		
					@current = 0.0
					@job_reflection.done = false
					@job_reflection.terminated = false
					@job_reflection.started = true
					@job_reflection.thread_id = Thread.current.object_id.to_s
					
					@job_reflection.save!
					
				end
					ActiveRecord::Base.connection_pool.with_connection do 
						@job_reflection.result  = work
					end

				sync do			
					unless @events.blank?
						@job_reflection.current = @current
						@job_reflection.save!
					end
				end

				unless @events.blank?
					while !@pad.done? except: @job_reflection

						Thread.pass
						sleep 0.5 #this sleep is important. It makes impact on events. Some time events block doesn't see changes in DB made from other threads
						check_events
					end
				end
				log "current1: #{@current}"
				log "jr.current1: #{@job_reflection.current}"	
			rescue => e
				puts "ThreadsPad::Job#wrapper:  #{@current}"
				#puts "ThreadsPad::Job#wrapper:  #{@job_reflection.current}"	
				puts "ThreadsPad::Job#wrapper: #{e.message}"

				e.backtrace.each {|msg| puts msg}
			ensure
				begin
					sync do
						

						@job_reflection.done = true
						log "jr.current11: #{@job_reflection.inspect}"	
						log "current2: #{@current}"

						@job_reflection.current = @current
						if @job_reflection.destroy_on_finish
							log "destroy_on_finish"
							@job_reflection.destroy
						else
							log "jr.current2: #{@job_reflection.inspect}"	
							
							#JobReflection.connection.commit_db_transaction
							@job_reflection.save!
							#this is workarround. I dunno why but when It saves it
							#@job_reflection get wierd/old attributes. 
							@job_reflection.current = @current
							@job_reflection.save
							log "jr.current3: #{@job_reflection.inspect}"	
						end
					
					end
				rescue => e
					puts "ThreadsPad::Job#wrapper2: #{e.message}"
				end

			end
			
			log "jr.current4: #{@job_reflection.current}"	
			#log "count: #{JobReflection.all.count}"
			ActiveRecord::Base.connection.close

		end
		def sync
			@cs = Mutex.new if @cs.nil?
			ActiveRecord::Base.connection_pool.with_connection do 
				if @cs.owned?
					yield
				else
					@cs.synchronize {	yield}
				end
			end
		end
	private
		def check_events
			return  if @events.nil? || @pad.nil?
			ActiveRecord::Base.connection_pool.with_connection do 
				tmp_events = @events
				tmp_events.each do |event|
					cond = event.first
					block = event.last
					
					calc_current = @pad.calc_current
					#puts "cond class name: #{cond.class.name}"
					#puts "cond #{cond}, calc_current #{calc_current}"
					if cond.is_a?(Range) && cond.include?(calc_current) ||
						cond.is_a?(Fixnum) && (cond == calc_current) ||
						cond.is_a?(Symbol) && @pad.done?(except: @job_reflection) && cond == :finish && calc_current >= 100
						
						block.call self
						@events.delete event
					
					end
				end
			end
		end
		def log msg
			#puts "[#{Thread.current.object_id}/#{@job_reflection.thread_id}] #{msg}"
		end
				
	end
end