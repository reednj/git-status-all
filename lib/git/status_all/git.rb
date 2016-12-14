module Git
	def self.repo? path
		begin
			self.open path
			return true
		rescue
			return false
		end
	end

	class Branch
		def up_to_date?
			ahead_count == 0 && behind_count == 0
		end

		def ahead
			origin = self.remotes(:origin)
			return [] if origin.nil?
			@base.log.between(origin.full, self.name)
		end

		def behind
			origin = self.remotes(:origin)
			return [] if origin.nil?
			@base.log.between(self.name, origin.full)
		end

		def ahead_count
			@ahead_count ||= ahead.count
		end

		def behind_count
			@behind_count ||= behind.count
		end

		def remotes(remote_name = nil)
			result = @base.branches.remote.select{|b| b.name == self.name }
			return result.select{|b| b.full.include? remote_name.to_s }.first unless remote_name.nil?
			return result 
		end
	end
end
