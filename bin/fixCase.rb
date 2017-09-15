#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'tempfile'
require 'fileutils'

if ARGV[-1] == 'DEBUG' # Enable remote debugger
  require 'byebug/core'
  require 'byebug'
  PORT = 8989
  STDOUT.puts "\n!!!---DEBUG Server started on localhost:#{PORT} @ " + Time.now.to_s + "\n\n"
  Byebug.wait_connection = true
  Byebug.start_server('127.0.0.1', PORT)
  ARGV.pop
  byebug
end

tstart = Time.now
infilename = ARGV[0]
out =  "===> Parsing BiBTeX file #{infilename} "
fail "Please specify an existing file!" unless infilename and File.exist?(infilename)

format = ARGV[1]
if format.nil? || !(format =~ /(bib|json)/)
	format = 'bib'
end

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
	"X-cell",
	"Y-cell",
	"X-cells",
	"Y-cells",
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
	"DREADD",
	"ROC",
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
	titleRegex = /^title/
when /json/
	titleRegex = /\s*"title": /
end

begin
	File.open(infilename, 'r') do |file|
		file.each_line("\r") do |line|
			if line.match(titleRegex)
				keepCase.each do | k |
					case format
					when /bib/
						line.gsub!(/\b#{k}\b/,"{#{k}}") #case sensitive
					when /json/
						line.gsub!(/\b#{k}\b/,"<span class=\"nocase\">#{k}</span>") #case sensitive
					end
				end
				enforceCase.each do | e |
					case format
					when /bib/
						line.gsub!(/\b#{e}\b/i,"{#{e}}") #case insensitive
					when /json/
						line.gsub!(/\b#{e}\b/i,"<span class=\"nocase\">#{e}</span>") #case sensitive
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
out += "... parsing took " + tend.to_s + "s"
puts out