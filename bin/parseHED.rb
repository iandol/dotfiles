require 'nokogiri'
#require 'debug/open_nonstop' # debugger, non-stop so insert `binding.break` where you want to stop

#binding.break

# Load the XML data from a file or a string
xml_data = File.read('/Users/ian/Downloads/HED8.3.0.xml') # or xml_data = '<root><person><name>John</name></person></root>'

# Parse the XML data using Nokogiri
doc = Nokogiri::XML(xml_data)

# Access the XML data as a Ruby data structure
root = doc.root
puts root.name # => "root"

# Iterate over the child elements
root.children.each do |child|
  puts child.name # => "person"
  child.children.each do |grandchild|
    puts grandchild.name # => "name"
    puts grandchild.text # => "John"
  end
end