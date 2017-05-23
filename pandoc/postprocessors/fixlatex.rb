#!/usr/bin/env ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

DEBUG = false
if DEBUG
	tstart = Time.now
	PORT = 8991 
	require 'byebug/core'
	require 'byebug'
	STDOUT.puts "\n!!!---DEBUG Server started on localhost:#{PORT} @ " + Time.now.to_s
	Byebug.wait_connection = true
	Byebug.start_server('localhost', PORT)
	byebug
end

input = $stdin.read
output = input.gsub(/⬄/, '{\fixfont⬄}')
output.gsub!(/⇨/, '{\\fixfont⇨}')
output.gsub!(/⇦/, '{\\fixfont⇦}')
output.gsub!(/\bmt\b/i, 'MT')
output.gsub!(/\bteo\b/i, 'TEO')
output.gsub!(/\btrn\b/i, 'TRN')
output.gsub!(/\bmst\b/i, 'MST')
output.gsub!(/\bgaba\b/i, 'GABA')
output.gsub!(/\bgabaergic\b/i, 'GABAergic')
output.gsub!(/\blgn\b/i, 'LGN')
output.gsub!(/\bv1\b/i, 'V1')
output.gsub!(/\bv2\b/i, 'V2')
output.gsub!(/\bv3\b/i, 'V3')
output.gsub!(/\bv4\b/i, 'V4')
output.gsub!(/\\begin\{quote\}/, '\begin{quote}\emph{')
output.gsub!(/\\end\{quote\}/, '}\end{quote}')
output.gsub!(/\\label{references}/, '\label{references}\singlespacing')

if DEBUG
	tend = Time.now - tstart
	output = output + " --- FIXLATEX PARSE TOOK: " + tend.to_s + " --- "
end
puts output