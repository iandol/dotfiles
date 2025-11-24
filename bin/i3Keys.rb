#!/usr/bin/env ruby

require 'open3'
require 'cgi'

# Fetch i3 config
config_output = `i3-msg -t get_config`

# Filter for bindsym lines, ignoring comments and empty lines
# The Perl script did: grep(/^bindsym/, grep(!/(^#)|(^\s*$)/, ...))
bindsyms = config_output.lines.select do |line|
  l = line.strip
  l.start_with?('bindsym') && !l.start_with?('#')
end

# Parse lines into key and command
key_to_cmd = bindsyms.map do |line|
  # Remove 'bindsym ' prefix
  content = line.strip.sub(/^bindsym\s+/, '')
  
  # Split into key and command
  # Perl regex was: /^(?<key>\S+)\s+(?<cmd>.+)$/
  match = content.match(/^(?<key>\S+)\s+(?<cmd>.+)$/)
  next unless match
  
  { key: match[:key], cmd: match[:cmd] }
end.compact

# Format items for rofi
dmenu_items = key_to_cmd.map do |item|
  # Escape HTML/XML special characters for Pango markup
  key = CGI.escapeHTML(item[:key])
  # Apply Pango markup
  formatted_key = "<span size='large' weight='heavy'>#{key}</span>"
  
  cmd = CGI.escapeHTML(item[:cmd])
  formatted_cmd = "\t\t#{cmd}"
  
  # Join with newline and append null byte separator
  "#{formatted_key}\n#{formatted_cmd}\0"
end

# Command to run rofi
# -sep '\0' tells rofi to use null byte as item separator
# -format i tells rofi to output the index (0-based) of the selected item
rofi_cmd = "rofi -dmenu -p 'i3 keybindings' -sep '\\0' -eh 2 -markup-rows -format i"

selected_index = nil
exit_status = nil

# Run rofi interactively
Open3.popen2(rofi_cmd) do |stdin, stdout, wait_thr|
  # Write all items to rofi's stdin
  dmenu_items.each { |item| stdin.print item }
  stdin.close
  
  # Read the output (selected index)
  output = stdout.read
  selected_index = output.strip.to_i if output && !output.empty?
  
  exit_status = wait_thr.value
end

# Check if rofi exited successfully (exit code 0)
if exit_status && exit_status.success? && selected_index
  # Retrieve the command corresponding to the selected index
  cmd = key_to_cmd[selected_index][:cmd]
  
  # Debug output (optional, matching Perl script's commented out logic)
  # STDERR.puts "STDOUT: [#{selected_index}] => [#{cmd}]"
  
  # Execute the i3 command
  system("i3-msg '#{cmd}'")
else
  # STDERR.puts "EXIT: #{exit_status.exitstatus}"
end
