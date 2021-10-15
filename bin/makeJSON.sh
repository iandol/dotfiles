#!/usr/bin/env zsh

cd $HOME/Dropbox/Papers/References
mydir=$(pwd)
if [[ $# -eq 0 ]]; then
	[[ -f "🌊Core.bib" ]] && mv 🌊Core.bib Core.bib
	filename="Core.bib"
else
	filename=$1
fi
printf "\n---> Processing Bibliography file $filename in $mydir @ $(date)...\n" >> sync.log
if [[ ! -s $filename ]]; then # make sure file exists
	printf "\nCannot find $filename\n" >> sync.log
	return -1
fi
if [[ ! -s $filename ]]; then # make sure file is not empty
	printf "\n$filename is empty!\n" >> sync.log
	return -1
fi
printf '\n---> Citeproc generating JSON from BIB file...\n' >> sync.log
/usr/local/bin/pandoc --verbose -f bibtex -t csljson $filename > Temp.json 2>> sync.log
if [[ ! -s Temp.json ]]; then
	printf "\nPandoc failed with $filename\n" >> sync.log
	return -1
fi
printf '\n---> Processing title case...\n' >> sync.log
/Users/ian/bin/fixCase.rb Temp.json
printf "---> Finshed processing title case...\n" >> sync.log
if [[ -s Temp.json ]]; then
	printf '\n---> Minifying JSON...\n' >> sync.log
	/usr/local/bin/jq -Sc '. | del(.[]."abstract",.[]."keyword",.[]."publisher-place")' < Temp.json > Core.json
else
	printf '---> ERROR: Temp.json does not exist or is empty\n' >> sync.log
fi
[[ -s Temp.json ]] && rm Temp.json
printf '\n---> ...Finished!\n' >> sync.log