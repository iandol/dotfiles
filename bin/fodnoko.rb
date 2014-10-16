#!/usr/bin/env ruby -w
require "nokogiri"
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

