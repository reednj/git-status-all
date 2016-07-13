require 'bundler'
Bundler.require

class App
	def main
		dev_dir = '/Users/reednj/Documents/dev/'
		repo_paths = Dir.entries(dev_dir).
			map {|p| { :name => p, :path => File.expand_path(p, dev_dir) } }.
			select { |p| Git.repo? p[:path] }
		
		repo_paths.each do |p|
			g = Git.open p[:path]
			s = file_status(g)
			r = remote_status(g)

			s = " #{s} ".black.on_yellow unless s.empty?
			puts "#{p[:name]}".pad_to_col(24).append(s).right_align("#{r}")
		end
	
	end

	def file_status(g)
		result = ""
		result += "A#{g.status.added.length}" if g.status.added.length > 0
		result += "D#{g.status.deleted.length}" if g.status.deleted.length > 0
		result += "M#{g.status.changed.length}" if g.status.changed.length > 0
		return result
	end

	def remote_status(g)
		if g.remotes.empty?
			return "no remotes".black.on_red
		end

		if g.remotes.select{|r| r.name.downcase == 'origin' }.empty?
			return "no origin".black.on_yellow
		end

		if !g.branches[:master].up_to_date?
			b = g.branches[:master]
			
			s = ''
			s += "#{b.behind_count} behind" if b.behind_count > 0
			s += ' / '  if b.ahead_count > 0 && b.behind_count > 0
			s += "#{b.ahead_count} ahead" if b.ahead_count > 0

			return s.black.on_green
		end

		return 'ok'.green.on_black
	end

	def term_width
		@term_width ||= `tput cols`.to_i
	end

end


class String
	def append(s)
		self + s
	end

	def pad_to_col(n)
		pad_amount = n - self.uncolorize.length
		return " " + s if pad_amount < 0
		return self + (" " * pad_amount)
	end

	def right_align(s)
		pad_amount = self._term_width - self.uncolorize.length - s.uncolorize.length
		return " " + s if pad_amount < 0
		return self + (" " * pad_amount) + s
	end

	def _term_width
		@term_width ||= `tput cols`.to_i
	end
end

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

App.new.main
