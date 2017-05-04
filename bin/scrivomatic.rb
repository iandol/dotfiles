#!/usr/bin/env ruby

require 'open3' # ruby standard library class to handle stderr and stdout
require 'optparse' # ruby standard option parser
require 'pp' #pretty print
#require 'pry'

class Scrivomatic
  attr_accessor :options
  attr_reader :version
  VER = '1.0.1'
  OPTIONS = Struct.new(:input,:output,:path,:verbose)
  
  def initialize # set up class
    puts "Initialising Scrivomatic..."
    @options = OPTIONS.new(nil,nil,nil,nil)
    @version = VER
  end
  
  def parseInputs(arg)
    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: Scrivomatic V" + @version + " -i FILE -o file -p path [options]"

      opts.on("-i", "--input FILE", "Input file") do |v|
        puts "Computing input"
        @options[:input] = v
      end
      
      opts.on("-o", "--output file", "Output file") do |v|
        puts "Computing output"
        @options[:output] = v
      end
      
      opts.on("-p", "--path dirpath", "Path to append") do |v|
        puts "Computing output"
        @options[:path] = v
      end
      

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        puts "Setting verbose"
        @options[:verbose] = v
      end
      
      opts.on("-h", "--help", "Prints this help") do
        puts "Calling help"
        puts optparse
        exit
      end
    end # end OptionParser
    
    def version=(verin)
      self.version = verin
    end
    
    optparse.parse!
    
  end # end parseInputs
end # end Scrivomatic

scr = Scrivomatic.new
scr.parseInputs(ARGV)

puts "=========scr======="
pp scr
#puts "=======optparse:======="
#puts scr.optparse
puts "=======Options:======="
pp scr.options
puts "=======Version:======="
puts "Scrivomatic version: V" + scr.version


#ENV['PATH'] = "/usr/local/bin:" + ENV['HOME'] + "/.rbenv/shims:" + ENV['PATH']
