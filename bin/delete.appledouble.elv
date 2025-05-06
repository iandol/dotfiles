#!/usr/bin/env elvish
# Elvish script to recursively delete files starting with "._"
# Usage: delete-appledouble.elv [--dry-run] [directory]

# Initialize variables
var dry-run = $false
var root-dir = (pwd)

# Parse arguments
each { |arg| 
  if (eq $arg '--dry-run') {
    set dry-run = $true
  } else {
    set root-dir = $arg
  }
} $args

echo 'Deleting AppleDouble files in: '$root-dir

# Use elvish 
var files = [$root-dir/**/._*[nomatch-ok]]

echo 'Found ._* files: '(count $files)

# Process each file
each { |file|
  if $dry-run {
    echo '[Dry Run] Would delete:' $file
  } else {
    echo 'Deleting:' $file
    rm $file
  }
} $files
