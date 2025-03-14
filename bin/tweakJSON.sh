#!/usr/bin/env zsh
# This script fixes Bookends JSON files for use with Pandoc
# tweakJSON.sh <infile> <outputname>
# If no outputname is given, the default is CoreFast.json
set -o errexit

if [[ $# -eq 2 ]]; then
	folder=$(dirname $1)
	infile=$(basename $1)
	outfile=$(basename $2)
elif [[ $# -eq 1 ]]; then
	folder=$(dirname $1)
	infile=$(basename $1)
	outfile="CoreFast.json"
else
	printf "Usage: tweakJSON.sh <infile> <outputname>\n"
	return -1
fi

cd $folder
mydir=$(pwd)

printf "\n\n======================================@$(date)\n"
printf "---> Processing Bibliography file $infile in $mydir\n"
if [[ -s $infile ]]; then
	printf '---> Minifying JSON...\n'
	if jq --sort-keys --tab '. | del(.[]."abstract",.[]."keyword",.[]."publisher-place")' < $infile > temp.json; then
		printf '---> JSON minification successful\n'
	else
		printf '---> ERROR: JSON minification failed\n'
		cp $infile temp.json
	fi
	printf '---> Fixing Dates...\n' # speed is sd > ruby > sed, use the one you have installed
	# sed version: sed 's/"raw": *".*\([0-9]\{4\}\)[^"]*"/"raw": "\1"/g' temp.json > $outfile
	# ruby -pi -e 'gsub /(?:"raw":\s*")(?:.*?)(\d{4})(?:[^"]*")/, "\"raw\": \"\\1\""' temp.json
	sd "(?:\"raw\":\s*\")(?:.*?)([0-9]{4})(?:[^\"]*\")" "\"raw\": \"\$1\"" temp.json
	mv temp.json $outfile
else
	printf '---> ERROR: infile does not exist or is empty\n'
fi

# my script to protect the case for defined words
printf '---> Processing title case...\n'
$HOME/bin/fixCase.rb $outfile
printf "---> Finshed processing title case...\n"

# link the optimised JSON to my pandoc data dir
printf '---> Link to pandoc data dir...\n'
ln -vfs $mydir/$outfile $HOME/.local/share/pandoc/$outfile

printf "======================================…written to $outfile!\n"