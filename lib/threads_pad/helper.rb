module ThreadsPad
	module Helper
		def filter_job_logs logs
			
			ret = []
			
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

			return ret
		end
	private
		def filter_job_logs_save l
			session[:thread_pad_log_filter] ||= {}
			ses = session[:thread_pad_log_filter]
			ses['last_log_id'] = l[:id] unless l[:id].nil?

		end
		def filter_job_log_exist? l
			ses =session[:thread_pad_log_filter]
			return false unless ses.has_key?('last_log_id')

			return ses['last_log_id'] >= l[:id].to_i

		end
	end
end
