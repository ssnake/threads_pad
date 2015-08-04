module ThreadsPad
	class SaveAdapter
		def before_work job

		end
		def after_work job
		end
	end
	class LogSaveAdapter < SaveAdapter
		def before_work job
			puts "before_work: #{job.inspect}"
		end
		def after_work job
			puts "after_work: #{job.inspect}"
		end
	end
end