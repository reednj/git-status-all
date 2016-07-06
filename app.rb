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

			s = "(#{s})" unless s.empty?

			puts "#{p[:name]} #{s}".right_align("[#{r}]") 
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
			return "no remotes"
		end

		if g.remotes.select{|r| r.name.downcase == 'origin' }.empty?
			return "no origin"
		end

		return "ok"
	end

	def term_width
		@term_width ||= `tput cols`.to_i
	end
end

class String
	def right_align(s)
		pad_amount = self._term_width - self.length - s.length
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
end

App.new.main
