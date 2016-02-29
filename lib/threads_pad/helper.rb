module ThreadsPad
	module Helper
		def filter_job_logs logs
			
			ret = []
			if logs.present?
				logs.sort { |x, y| x[:id] <=> y[:id]}. each do |l|

					if session.has_key? :thread_pad_log_filter
						unless filter_job_log_exist?(l)	
							filter_job_logs_save l
							ret << l
						else					

						end
					else
						filter_job_logs_save l
						ret << l
					end
				end
			end

			return ret
		end
	private
		def filter_job_logs_save l
			return if l[:id].nil? || l[:job_reflection_id].nil? 
			ses = session[:thread_pad_log_filter] || {}
			key = l[:job_reflection_id]
			val = l[:id]
			ses[key] = val
			session[:thread_pad_log_filter] = ses


		end
		def filter_job_log_exist? l
			return true if l[:id].nil? || l[:job_reflection_id].nil? 

			ses = session[:thread_pad_log_filter]
			key = l[:job_reflection_id]
			val = l[:id]
			if ses.has_key? key
				ses[key].to_i >= l[:id].to_i
			else
				false
			end

			

			

		end
	end
end
