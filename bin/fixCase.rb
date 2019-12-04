#!/usr/bin/env ruby
#encoding: utf-8

# version = 1.0.2

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'tempfile'
require 'fileutils'

tstart = Time.now
infilename = File.expand_path(ARGV[0])
raise 'Please specify an existing file!' unless infilename && File.exist?(infilename)

format = ARGV[1]
if format.nil? || format !~ /(bib|json)/
	infilename =~ /\.json$/ ? format = 'json' : format = 'bib'
end

print "===> Parsing #{format} Bibliography file: #{infilename} ..."

# only wrap with {} IF the word is already the case in this list
keepCase = [
	'ON',
	'OFF',
	'BETA',
	'GAMMA',
	'ALPHA',
	'X', # X cells
	'Y', # Y cells
	'W', # W cells
	'M', # magnocellular
	'P', # parvocellular
]

# always force this word to be a certain case
enforceCase = [
	'X-cell',
	'Y-cell',
	'X-cells',
	'Y-cells',
	'LGN',
	'dLGN',
	'TRN',
	'RTN',
	'V1',
	'V2',
	'V3',
	'V4',
	'V4d',
	'V4v',
	'V5',
	'V6',
	'V6a',
	'MT',
	'MST',
	'hMT+',
	'8A',
	'FEF',
	'mPFC',
	'VIP',
	'mGlu1',
	'GluR',
	'NMDA',
	'NMDAR1',
	'AMPA',
	'GABA',
	'GABAergic',
	'DNA',
	'RNA',
	'LFP',
	'DREADD',
	'ROC',
	'fMRI',
	'tDCS',
	'EEG',
	'VEP',
	'AAV',
	'rAAV',
	'OTX2',
	'TMS',
	'MEG',
	'2D',
	'3D',
	'HMAX',
	'R-CNN',
	'DCNN',
	'NCC'
]

temp_file = Tempfile.new('fixcase')
case format
when /bib/
	titleRegex = /^\s*title = /
	abstractRegex = /^\s*abstract = /
when /json/
	titleRegex = /^\s*"title": /
	abstractRegex = /^\s*"abstract": /
end

# cusom boundaries, more specific than the generic \b
b1 = Regexp.escape("'\"/,.[(-–—")
b2 = Regexp.escape("'\"/,.]):-–—")

begin
	File.open(infilename, 'r') do |file|
		file.each_line do |line|
			line.gsub!(/\r+$/, "\n")
			if line.match(titleRegex)

				keepCase.each do |k|
					r = /(?<=[\s#{b1}])#{k}(?=[\s#{b2}])/ # case sensitive
					case format
					when /bib/
						line.gsub!(r, "{#{k}}") if line.match(r)
						sr = /title = {#{k}(?=\b)/ # deal with start-of-title words
						er = /(?<=\b)#{k}},\s+\n/ # deal with end-of-title words
						line.gsub!(sr, "title = {{#{k}}") if line.match(sr)
						line.gsub!(er, "{#{k}}}, \n") if line.match(er)
					when /json/
						if line.match(r)
							line.gsub!(r, "<span class=\\\"nocase\\\">#{k}</span>") # case sensitive
						end
					end
					# rr = /#{k}},\s\n/
				end

				enforceCase.each do |e|
					r = /(?<=[\s#{b1}])#{e}(?=[\s#{b2}])/i # case insensitive
					case format
					when /bib/
						line.gsub!(r, "{#{e}}") if line.match(r)
						sr = /title = {#{e}(?=\b)/i # deal with start-of-title words
						er = /(?<=\b)#{e}},\s+\n/i # deal with end-of-title words
						line.gsub!(sr, "title = {{#{e}}") if line.match(sr)
						line.gsub!(er, "{#{e}}}, \n") if line.match(er)
					when /json/
						if line.match(r)
							line.gsub!(r, "<span class=\\\"nocase\\\">#{e}</span>") # case sensitive
						end
					end
				end

			end
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
puts '... parsing took ' + tend.to_s + 's'
