#!/usr/bin/env ruby
#encoding: utf-8

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

input = $stdin.read
output = input.gsub(/(^\*\*Affiliations[^\n]+)/, "\n")

puts output
