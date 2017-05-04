#!/usr/bin/env ruby

require 'open3' # ruby standard library class to handle stderr and stdout
require 'optparse' # ruby standard option parser
require 'pp' #pretty print
require 'pry'

class Scrivomatic
  attr_accessor :options, :input, :output, :path, :verbose
  attr_reader :version
  VER = '1.0.1'
  OPTIONS = Struct.new(:input,:output,:path,:verbose)
  
  def initialize # set up class
    puts "Initialising Scrivomatic..."
    self.options = OPTIONS.new(nil,nil,nil,nil)
    self.input = self.options[:input]
    self.output = self.options[:output]
    self.path = self.options[:path]
    self.verbose = false
    self.version = VER
  end
  
  def parseInputs(arg)
    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: Scrivomatic V" + self.version + " -i FILE -o file -p path [options]"
      
      self.input = self.options[:input]
      opts.on("-i", "--input FILE", "Input file") do |v|
        puts "Computing input"
        self.options[:input] = v
        self.input = v
      end
      
      self.output = self.options[:output]
      opts.on("-o", "--output file", "Output file") do |v|
        puts "Computing output"
        self.options[:output] = v
        self.output = v
      end
      
      self.path = self.options[:path]
      opts.on("-p", "--path dirpath", "Path to append") do |v|
        puts "Computing output"
        self.options[:path] = v
        self.path = v
      end
      
      self.options[:verbose] = false
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        puts "Setting verbose"
        self.options[:verbose] = v
        self.verbose = v
      end
      
      opts.on("-h", "--help", "Prints this help") do
        puts "Calling help"
        puts self.optparse
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
puts scr.input
puts "=======optparse:======="
#puts scr.optparse
puts "=======Options:======="
pp scr.options
puts "=======Version:======="
puts "Scrivomatic version: V" + scr.version


#ENV['PATH'] = "/usr/local/bin:" + ENV['HOME'] + "/.rbenv/shims:" + ENV['PATH']
