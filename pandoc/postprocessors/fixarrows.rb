#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

DEBUG = false
if DEBUG
	PORT = 8991 
	require 'byebug/core'
	require 'byebug'
	STDOUT.puts "\n!!!---DEBUG Server started on localhost:#{PORT} @ " + Time.now.to_s
	Byebug.wait_connection = true
	Byebug.start_server('localhost', PORT)
	byebug
end

input = $stdin.read
output = input.gsub(/⬄/, '{\\fixfont⬄}')
output.gsub!(/([\s\(\[\{])mt([\s\.\)\]\}])/i, '\1MT\2')
output.gsub!(/([\s\(\[\{])lgn([\s\.\)\]\}])/i, '\1LGN\2')
output.gsub!(/([\s\(\[\{])v1([\s\.\)\]\}])/i, '\1V1\2')
output.gsub!(/([\s\(\[\{])v2([\s\.\)\]\}])/i, '\1V2\2')
output.gsub!(/([\s\(\[\{])v3([\s\.\)\]\}])/i, '\1V3\2')
output.gsub!(/([\s\(\[\{])v4([\s\.\)\]\}])/i, '\1V4\2')
output.gsub!(/\\begin\{quote\}/, '\begin{quote}\n\emph{')
output.gsub!(/\\end\{quote\}/, '}\n\end{quote}')
puts output