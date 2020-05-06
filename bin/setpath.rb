#!/usr/bin/env ruby

require 'open3' # ruby standard library class to handle stderr and stdout

STDOUT.puts "\n\n=====================setpath.rb @ " + `date`
STDOUT.puts "---SHELL PATH: " + `echo $PATH 2>&1`

STDOUT.puts "\n---ENV PATH: " + ENV['PATH']

ENV['PATH'] = "/usr/local/bin:" + ENV['HOME'] + "/.rbenv/shims:" + ENV['PATH']

STDOUT.puts "\n---MODIFIED PATH: " + ENV['PATH']

STDOUT.puts "\n---USER: " + `echo $USER`
STDOUT.puts "---PWD: " + `echo $PWD`
STDOUT.puts "---HOME: " + `echo $HOME`
STDOUT.puts "---SHELL: " + `echo $SHELL`
STDOUT.puts "---PATH: " + `echo $PATH`

STDOUT.puts `echo "---ruby: $(which ruby)" `
STDOUT.puts `ruby -v`
STDOUT.puts `echo "---rbenv: $(which rbenv)"` 
STDOUT.puts `rbenv versions`
STDOUT.puts `echo "---pandoc: $(which pandoc)" `
STDOUT.puts `echo "---panzer: $(which panzer)" `
STDOUT.puts `echo "---pandocomatic: $(which pandocomatic)" `

pd = `which pandocomatic`.chomp
STDOUT.puts "Pandocomatic present at #{pd}, will get version..."

if File.exist?(pd)
  cmd = pd + ' -v'
  STDOUT.puts "CMD to RUN: " + cmd
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    while line = stdout.gets
      STDOUT.puts "::: " + line
    end
    exit_status = wait_thr.value
      unless exit_status.success?
        abort "FAILED !!! #{cmd}"
      end
  end
else
  STDOUT.puts "Pandocomatic doesn't exist!"
end
