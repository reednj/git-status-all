require 'git'
require 'colorize'
require 'optimist'

require "git/status_all/version"
require "git/status_all/extensions"
require "git/status_all/git"

module Git
  module StatusAll
	class App
		def main
			# we want to disable the text coloring if we are printing to a
			# file, or on a platform (like windows) that likely doesn't support
			# the colors
			String.disable_colorization = !$stdout.isatty
			
			opts = Optimist::options do
				version "git-status-all #{Git::StatusAll::VERSION} (c) 2016 @reednj (reednj@gmail.com)"
				banner "Usage: git-status-all [options] [path]"
				opt :fetch, "perform fetch for each repository before getting status", :default => false
			end

			repo_paths = []

			begin
				dev_dir = ARGV.last || '.'
				repo_paths = Dir.entries(dev_dir).
					map {|p| { :name => p, :path => File.expand_path(p, dev_dir) } }.
					select { |p| Git.repo? p[:path] }
			rescue => e
				$stderr.puts "Could not read repositories in '#{dev_dir}': #{e}"
			end

			repo_paths.each do |p|
				name = p[:name]
				
				begin
					g = Git.open p[:path]
					
					if opts[:fetch]
						print "#{name}".right_align("[#{"fetching...".yellow}]") + "\r"
						
						if !g.remotes.empty?
							remote = g.remotes.select{|r| r.name.downcase == 'origin' }.first || g.remotes.first
							g.fetch remote
						end
					end

					s = file_status(g)
					r = remote_status(g)
					s = " #{s} ".black.on_yellow unless s.empty?
					n = s.empty? ? name : name.yellow 
					puts "#{n}".pad_to_col(24).append(s).right_align("#{r} [#{g.branches.current.to_s.blue}]")
				rescue => e
					if e.to_s.include? "ambiguous argument 'HEAD'"
						err ='ERROR: NO HEAD'
					else
						err ='ERROR'
					end

					puts "#{name}".right_align("[#{err}]".red)	
					puts e.to_s if err == 'ERROR'
				end
			end
		
		end

		def file_status(g)
			result = ""
			result += "A#{g.status.added.length}" if g.status.added.length > 0
			result += "D#{g.status.deleted.length}" if g.status.deleted.length > 0
			result += "M#{g.status.changed.length}" if g.status.changed.length > 0
			result += "U#{g.status.untracked.length}" if g.status.untracked.length > 0
			return result
		end

		def remote_status(g)
			if g.remotes.empty?
				return "no remotes".black.on_red
			end

			if g.remotes.select{|r| r.name.downcase == 'origin' }.empty?
				return "no origin".black.on_yellow
			end

			if !g.branches.current.up_to_date?
				b = g.branches.current
				
				s = ''
				s += "#{b.behind_count}\u2193" if b.behind_count > 0
				s += "#{b.ahead_count}\u2191" if b.ahead_count > 0

				return s.green
			end

			return ''
		end

		def term_width
			@term_width ||= `tput cols`.to_i
		end

	end
  end
end
