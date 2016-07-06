require 'bundler'
Bundler.require

class App
	def main
		dev_dir = '/Users/reednj/Documents/dev/'
		repo_paths = Dir.entries(dev_dir).
			map{|p| File.expand_path(p, dev_dir) }.
			select { |p| Git.repo? p }
		
		repo_paths.each do |p|
			puts p
		end
		
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
