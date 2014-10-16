#!/usr/bin/env ruby -w
#require "rexml/document"
require "profile"
filename = ARGV[0]
fail "Please specify an existing file!" unless filename and File.exists?(filename)

File.open(filename, "r+") do |f|
	fout = []
	linenum = 1
	re = [ /svg:width="95%"/,
		/style:print-content="false"/,
		/style:font-name="Courier New"/,
		/<style:paragraph-properties fo:margin-left="0.3937in"/,
		/<text:p text:style-name="Horizontal_20_Line"\/>/,
		/<text:h text:outline-level="0">/,
		/text:bullet-char=""/ ]
	rep = ['style:rel-width="99%"',
		'style:print-content="true"',
		'style:font-name="Menlo"',
		'<style:text-properties fo:font-style="italic" style:font-style-complex="italic"/><style:paragraph-properties fo:margin-left="0.3937in"',
		'',
		'<text:h text:outline-level="0">',
		'text:bullet-char="•"']
	
	lines = f.readlines

	lines.each do |line|
		renum = 0
		re.each do |regex|
			if line=~regex
				line.gsub!(regex,rep[renum])
				puts linenum.to_s + ":" + renum.to_s + " = " + line
			end
			renum += 1
		end

		fout.push(line)
		linenum += 1
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

#if line=~/svg\:width\=\"\d\d\%\"/
#			#puts a.to_s + " = " + f.pos.to_s + ": {" + f.getc + "}"
#			puts a.to_s + " = " + line
#			line.gsub!(/svg\:width\=\"\d\d\%\"/, 'rel-width="100%" svg:width="100%"')
#			puts line
#		end
#		if line=~/style\:print\-content\=\"false\"/
#			puts a.to_s + " = " + line
#			line.gsub!(/svg\:width\=\"\d\d\%\"/, 'rel-width="100%" svg:width="100%"')
#			puts line
#		end
#		if line=~/style:font-name="Courier New"/ 
#			puts a.to_s + " = " + line
#			line.gsub!(/style:font-name="Courier New"/, 'style:font-name="Menlo"')
#			puts line
#		end
#		if line =~/style:paragraph-properties fo:margin-left="0.3937in"/
#			puts a.to_s + " = " + line
#			line.gsub!(/style:font-name="Courier New"/, 'style:font-name="Menlo"')
#  puts "Hello, XML parsing is good to go!"
#  doc = REXML::Document.new(f)
#  puts doc.name
#  a=1
#  REXML::XPath.each(doc, '*/*/*/*/draw:frame') do |frame|
#    puts a.to_s + ": " + frame.attributes["draw:style-name"]
#    if frame.attributes["svg:width"] == "95%"
#      frame.attributes["rel-width"] = "100%"
#      frame.attributes["svg:width"] = "100%"
#    end
#    a = a+1;
#  end
#  
#  filename = "XML.fodt"
#  File.open(filename, "w") do |ff|
#    puts "Trying to write output to " + filename
#    doc.write(:output => ff)
#  end
#end

