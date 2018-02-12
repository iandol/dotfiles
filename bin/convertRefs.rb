#!/usr/bin/env ruby
#encoding: utf-8

require 'tempfile'
require 'fileutils'

# this converts to -e line format so osascript can run, pass in a heredoc
# beware this splits on \n so can't include them in the applescript itself
def osascript(script)
	cmd = ['osascript'] + script.split(/\n/).map { |line| ['-e', line] }.flatten
	IO.popen(cmd) { |io| return io.read }
end

tstart = Time.now
infilename = ARGV[0]
fail "Please specify an existing file!" unless infilename and File.exist?(infilename)

if ARGV.length > 1
	groupname = ARGV[1]
end

puts "===> Parsing Markdown file: #{infilename}..."

outfilename = 'convert_' + infilename

temp_file = Tempfile.new('fixcase')

tempCite = /(-?@{1})(\w{1,20}\d{4}\w{0,2})/
lineSeparator = "\n"

begin
	groupids = ""
	i = 0
	key = []
	File.open(infilename, 'r') do |file|
		file.each_line(lineSeparator) do |line|
			line.gsub!(/\[\@/,"{@")
			line.scan(tempCite) do |w| 
				fragment = w[0]
				key[i] = w[1]
				i += 1
			end
			line.gsub!(tempCite,"\\2")
			line.gsub!(/(\{[^\]^\}]+)(\])/, "\\1}")
			line.gsub!(/\r+$/, "\n")
			temp_file.puts line
		end
	end
	temp_file.close
	FileUtils.mv(temp_file.path, outfilename)
ensure
	temp_file.close
	temp_file.unlink
end

if groupname && !key.empty?
	uuid = []
	key.uniq!
	key.each_with_index do |thiskey,i|
		uuid[i] = osascript <<-EOT
		tell application "Bookends"
			return «event ToySSQLS» "user1 REGEX '^#{thiskey}$' "
		end tell
		EOT
		uuid[i] = uuid[i].chomp.strip
	end
	
	puts "Adding the scanned refs to group: #{groupname}"
	worked = osascript <<-EOT
	tell application "Bookends"
		return «event ToySADDG» "#{groupname}" given string:"#{uuid.join(',')}"
	end tell
	EOT
	puts "Return value: " + worked
end

tend = Time.now - tstart
puts "... parsing took " + tend.to_s + "s"
