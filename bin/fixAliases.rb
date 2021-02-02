#!/usr/bin/env ruby
#encoding: utf-8

# This traverses a Scrivener project and finds alias files (binary start=book....mark) and 
# adds com.Finder.FinderInfo metadata to make sure macOs recognises them...
# version = 1.0.0

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'fileutils'

fail "Please specify a Scrivener Project!" unless ARGV[0] and File.exist?(ARGV[0])

tstart = Time.now
infilename = File.expand_path(ARGV[0]) + '/Files/Data'

fail "Please specify a valid Scrivener Project!" unless infilename and File.exist?(infilename)

puts "===> Parsing Folder: #{infilename}..."

def traverse(path='.')
	Dir.entries(path).each do |name|
		next  if name == '.' or name == '..'
		path2 = path + '/' + name
		if File.ftype(path2) == "directory"
			traverse(path2)
		else
			process(path2)
		end
	end
end

def process(path)
	return if File.ftype(path) == "directory"
	cmd = "xxd -ps -l12 '#{path}'"
	firstBytes = `#{cmd}`.chomp
	if firstBytes =~ /626f6f6b000000006d61726b/ # first 12 bytes read book....mark which is an alias file
		puts "Processing #{path} as an alias..."
		ret = `xattr -wx com.apple.FinderInfo 616C69734D414353800000000000000000000000000000000000000000000000 "#{path}"`
	end
end

traverse(infilename)

tend = Time.now - tstart
puts "... parsing took " + tend.to_s + "s"