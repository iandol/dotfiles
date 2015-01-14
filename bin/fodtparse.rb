#!/usr/bin/env ruby -w
#require "profile"
#require "pry"

infilename = ARGV[0]
fail "Please specify an existing file!" unless infilename and File.exists?(infilename)

#=========check if .md file is passed, if so parse it to fodt
ismd =  /\.md$/
if infilename =~ ismd
	puts "===> Converting MD to FODT..."
	c = `which mmd2odf`.sub!(/\n$/," ") + infilename.sub(/ /,"\\ ") #build command
	puts "===> Command to execute: " + c
	x = system(c)
	puts "===> Check for FODT file..."
	filename = infilename.sub(ismd,".fodt")
	puts "===> New filename: " + filename
else
	filename = infilename
end

fail "===> No FODT file present!" unless filename =~ /fodt$/ and File.exists?(filename)
#binding.pry #use PRY to examine state
File.open(filename, "r+") do |f|
	fout = []
	linenum = 0
	re = [ /svg:width="95%"/, #use more space for frames
		/style:print-content="false"/, #Fix PDF generation not including images
		/style:font-name="Courier New"/, #kill courier new
		/style:font-name-asian="Courier New"/,#kill courier new
		/style:font-name-complex="Courier New"/,#kill courier new
		/<style:paragraph-properties fo:margin-left="0\.3937in"/, #quotations
		/                               fo:text-align="justify"/, #quotations
		/<text:p text:style-name="Horizontal_20_Line"\/>/, #kill HR
		/<text:h text:outline-level="0">/,
		/text:bullet-char=""/,
		/<style:header><text:h text:outline-level="2">Bibliography<\/text:h><\/style:header><\/style:master-page>/ ]
	rep = ['style:rel-width="100%"',
		'style:print-content="true"',
		'style:font-name="Menlo"',
		'style:font-name-asian="Menlo"',
		'style:font-name-complex="Menlo"',
		'<style:text-properties fo:font-style="italic" style:font-style-complex="italic"/><style:paragraph-properties fo:margin-left="0.3937in"',
		'fo:text-align="left"',
		'',
		'<text:h text:outline-level="0">',
		'text:bullet-char="•"',
		'</style:master-page>']
	
	lines = f.readlines

	lines.each do |line|
	linenum += 1
		renum = 0
		re.each do |regex|
			if line=~regex
				line.gsub!(regex,rep[renum])
				puts ">>" + linenum.to_s + ":" + renum.to_s + " = " + line
			end
			renum += 1
		end
		fout.push(line)
	end

	puts "TOTAL Lines: " + linenum.to_s
	puts "OUT Lines:" + fout.length.to_s

	newfilename = filename.gsub(/\.fodt/,'PARSE.fodt')
	File.open(newfilename, "w") do |ff|
		puts "Trying to write output to " + newfilename
		fout.each do |line|
			ff.puts(line)
		end
	end

end
