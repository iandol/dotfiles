#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

DEBUG = true
if DEBUG
	PORT = 8991 
	require 'byebug/core'
	require 'byebug'
	STDOUT.puts "\n!!!---DEBUG Server started on localhost:#{PORT} @ " + Time.now.to_s
	Byebug.wait_connection = true
	Byebug.start_server('localhost', PORT)
	byebug
end

input = STDIN.gets
output = input.gsub(/⬄/, "{\fixfont⬄}")
return