#!/usr/bin/env ruby -w
#require "rexml/document"
#require "profile"
infilename = ARGV[0]
fail "Please specify an existing file!" unless infilename and File.exists?(infilename)

ismd =  /\.md$/
if infilename =~ ismd
  puts "===> Converting MD to FODT..."
  c = `which mmd2odf`
  c = c.sub!(/\n$/," ")
  c = c + infilename.sub(/ /,"\\ ")
  puts "===> Command: " + c
  x = system(c)
  puts("===> mmd command executed: " + x.to_s)
  puts "===> Check for FODT file..."
  filename = infilename.sub(ismd,".fodt")
  fail "No FODT file present!" unless File.exists?(filename)
  puts "===> New filename: " + filename
else
  filename = infilename
end

fail "No FODT file present!" unless filename =~ /fodt$/ and File.exists?(filename)

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
		/text:bullet-char=""/ ]
	rep = ['style:rel-width="99%"',
		'style:print-content="true"',
		'style:font-name="Menlo"',
    'style:font-name-asian="Menlo"',
    'style:font-name-complex="Menlo"',
		'<style:text-properties fo:font-style="italic" style:font-style-complex="italic"/><style:paragraph-properties fo:margin-left="0.3937in"',
		'fo:text-align="left"',
		'',
		'<text:h text:outline-level="0">',
		'text:bullet-char="•"']
	
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

