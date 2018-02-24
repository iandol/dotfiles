#!/usr/bin/env ruby
#encoding: utf-8

require 'tempfile'
require 'fileutils'

tstart = Time.now
infilename = ARGV[0]
fail "Please specify an existing file!" unless infilename and File.exist?(infilename)

format = ARGV[1]
if format.nil? || !(format =~ /(bib|json)/)
	if infilename.match(/\.json$/)
		format = 'json'
	else
		format = 'bib'
	end
end

print "===> Parsing #{format} Bibliography file: #{infilename} ..."

#only wrap with {} IF the word is already the case in this list
keepCase = [
	"ON",
	"OFF",
	"BETA",
	"GAMMA",
	"ALPHA",
	"X", #X cells
	"Y", #Y cells
	"W", #W cells
	"M", #magnocellular
	"P", #parvocellular
]

# always force this word to be a certain case
enforceCase = [
	"X-cell",	"Y-cell",	"X-cells",	"Y-cells",
	"V1",
	"V2",
	"V3",
	"V4",
	"V4d",
	"V4v",
	"V5",
	"V6",
	"V6a",
	"MT",
	"MST",
	"DNA",
	"RNA",
	"TRN",
	"RTN",
	"FEF",
	"mPFC",
	"VIP",
	"mGlu1",
	"GluR",
	"NMDA",
	"AMPA",
	"GABA",
	"GABAergic",
	"LGN",
	"dLGN",
	"LFP",
	"DREADD",
	"ROC",
	"fMRI",
	"tDCS",
	"EEG",
	"AAV",
	"TMS",
	"MEG",
	"2D",
	"3D",
	"HMAX",
	"R-CNN",
	"DCNN",
	"NCC"]

temp_file = Tempfile.new('fixcase')
case format 
when /bib/
	titleRegex = /^\s*title = /
when /json/
	titleRegex = /^\s*"title": /
end

#cusom boundarys, more specific than the generic \b 
b1 = Regexp.escape("'\",.[(-–—")
b2 = Regexp.escape("'\",.])-–—")

begin
	File.open(infilename, 'r') do |file|
		file.each_line do |line|
			if line.match(titleRegex)
				keepCase.each do | k |
					r = /(?<=[\s#{b1}])#{k}(?=[\s#{b2}])/
					if line.match(r)
						case format
						when /bib/
							line.gsub!(r, "{#{k}}") #case sensitive
						when /json/
							line.gsub!(r, "<span class=\\\"nocase\\\">#{k}</span>") #case sensitive
						end
					end
				end
				enforceCase.each do | e |
					r = /(?<=[\s#{b1}])#{e}(?=[\s#{b2}])/i
					if line.match(r)
						case format
						when /bib/
							line.gsub!(r, "{#{e}}") #case insensitive
						when /json/
							line.gsub!(r, "<span class=\\\"nocase\\\">#{e}</span>") #case sensitive
						end
					end
				end
			end
			line.gsub!(/\r+$/, "\n")
			temp_file.puts line
		end
	end
	temp_file.close
	FileUtils.mv(temp_file.path, infilename)
ensure
	temp_file.close
	temp_file.unlink
end

tend = Time.now - tstart
puts "... parsing took " + tend.to_s + "s"
