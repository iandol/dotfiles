#!/usr/bin/ruby

if ARGV.index('-o')
	fname = ARGV[ARGV.index('-o') + 1]
else
	STDOUT.puts "STDOUT: Here is where STDOUT ends up, we could put the intended data output here."
	STDERR.puts "STDERR: This is an error message, now we'll dump out of the script."
	fail "No output filename specified: use '-o filename.txt'"
end

if ARGV.index('-i')
	iname = ARGV[ARGV.index('-i') + 1]
else
	iname = "No input filename"
end

File.open(fname, 'w') { |f| f.puts "Test Run for file: " + iname + " path: " + Dir.pwd }
STDOUT.puts "STDOUT: This could be for logging purposes or for actual output."
STDERR.puts "STDERR: Normally we won't see this, but we could if redirection is used."
