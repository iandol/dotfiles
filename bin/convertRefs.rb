#!/usr/bin/env ruby
#encoding: utf-8

require 'tempfile'
require 'fileutils'

# this converts to -e line format so osascript can run, pass in a heredoc
# beware this splits on \n so can't include them in the applescript itself
def osascript(script)
	cmd = ['osascript'] + script.split(/\n/).map { |line| ['-e', line] }.flatten
	IO.popen(cmd) { |f| return f.read }
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
	File.open(infilename, 'r') do |file|
		file.each_line(lineSeparator) do |line|
			line.gsub!(/\[\@/,"{@")
			line.scan(tempCite) do |w| 
				fragment = w[0]
				key = w[1]
				uuid = osascript <<-EOT
				tell application "Bookends"
					return «event ToySSQLS» "user1 REGEX '^#{key}$' "
				end tell
				EOT
				uuid.chomp!.strip!
				groupids.empty? ? groupids += uuid : groupids += ',' + uuid
				puts "==> " + w.to_s + " > " + uuid.to_s
			end
			line.gsub!(tempCite,"\\2")
			line.gsub!(/(\{[^\]^\}]+)(\])/, "\\1}")
			line.gsub!(/\r+$/, "\n")
			temp_file.puts line
		end
	end
	temp_file.close
	FileUtils.mv(temp_file.path, outfilename)
	if groupname
		puts "Adding the scanned refs to group: #{groupname}"
		worked = osascript <<-EOT
		tell application "Bookends"
			return «event ToySADDG» "#{groupname}" given string:"#{groupids}"
		end tell
		EOT
		puts "Return: " + worked
	end
ensure
	temp_file.close
	temp_file.unlink
end

tend = Time.now - tstart
puts "... parsing took " + tend.to_s + "s"
