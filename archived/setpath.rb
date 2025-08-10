#!/usr/bin/env ruby

require 'open3' # ruby standard library class to handle stderr and stdout
#require 'debug/open_nonstop' # debugger, non-stop so insert `binding.break` where you want to stop

STDOUT.puts "\n\n=====================setpath.rb @ " + `date`
STDOUT.puts ' Running shell: ' + `printf $SHELL`
STDOUT.puts ' Working directory: ' + `pwd`
STDOUT.puts " Initiating with Ruby #{RUBY_VERSION}"
STDOUT.puts "---INITIAL PATH: " + `echo $PATH 2>&1`

STDOUT.puts "\n---ENV PATH: " + ENV['PATH']

#binding.break

ENV['PATH'] = "/opt/homebrew/bin:" + "/usr/local/bin:" + ENV['HOME'] + "/.rbenv/shims:" + ENV['PATH']

STDOUT.puts "\n---MODIFIED PATH: " + ENV['PATH']

STDOUT.puts "\n---USER: " + `echo $USER`
STDOUT.puts "---PWD: " + `echo $PWD`
STDOUT.puts "---HOME: " + `echo $HOME`
STDOUT.puts "---SHELL: " + `echo $SHELL`
STDOUT.puts "---SHELL PATH: " + `echo $PATH`

STDOUT.puts `echo "---ruby: $(which ruby)" `
STDOUT.puts "--ruby version: " + `ruby -v`
begin STDOUT.puts `echo "---rbenv: $(which rbenv)"` end
begin STDOUT.puts "---rbenv versions:\n" + `rbenv versions` end
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
