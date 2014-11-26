#!/usr/bin/env ruby -w
require "nokogiri"
#require "rexml/document"
#require "profile"
filename = ARGV[0]
fail "Please specify an existing file!" unless filename and File.exists?(filename)

File.open(filename, "r+") do |f|
	
	puts "Hello, XML parsing is good to go!"
	@doc = Nokogiri::XML(f)

	a = 1
	@doc.xpath("//style:style").each do | style |
		puts a.to_s + ": " + style.to_s
		puts style
		puts
		puts
		a += 1
	end

	#newfilename = filename.gsub(/\.fodt/,'NOKO.fodt')
	#File.open(newfilename, "w") do |ff|
		
	#end

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

