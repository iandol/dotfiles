#!/usr/bin/env ruby

STDERR.puts "---PATH: " + `echo $PATH`
`export DROOPY=12`
`export PATH=$HOME/.rbenv/shims:/usr/local/bin:$HOME/bin:$PATH`
if $?.exitstatus > 0
  STDERR.puts "I failed to export PATH, I am very sorry :'(" 
end
STDERR.puts "---USER: " + `echo $USER`
STDERR.puts "---PWD: " + `echo $PWD`
STDERR.puts "---HOME: " + `echo $HOME`
STDERR.puts "---SHELL: " + `echo $SHELL`
STDERR.puts "---PATH: " + `echo $PATH`
STDERR.puts "---DROOPY: " + `echo $DROOPY`

if ARGV.index('-o')
	outname = ARGV[ARGV.index('-o') + 1]
else
	STDOUT.puts "STDOUT 1: Here is where STDOUT ends up, we could put the intended data output here."
	STDERR.puts "STDERR 1: This is an error message, now we'll dump out of the script."
	STDERR.puts "WHICH pandoc: " + `which pandoc`	
	STDERR.puts "WHICH panzer: " + `which panzer`
	STDERR.puts "WHICH pandocomatic: " + `which pandocomatic`
	STDERR.puts "WHICH ruby: " + `which ruby`
	STDERR.puts "pandocomatic -v: " + `pandocomatic -v`
	fail "No output filename specified: use '-o filename.txt'"
end

if ARGV.index('-i')
	inname = ARGV[ARGV.index('-i') + 1]
else
	inname = "No input filename"
end

File.open(outname, 'w') { |f| f.puts "Test Run for file: " + inname + " path: " + Dir.pwd }
STDOUT.puts "STDOUT 2: This could be for logging purposes or for actual output."
STDERR.puts "STDERR 2: Normally we won't see this, but we could if redirection is used."

