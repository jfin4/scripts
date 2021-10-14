#!/bin/sh
# convert pdf files to text for easy searching

if [ -z "$1" ]
then
	printf "%s\n" "Usage: $0 <dir>"
	exit
fi

root_in="$1"
root_out="${1}-text"

# create list of files to convert
temp=$(mktemp)
fd -e pdf . "$root_in" > $temp

# how many files to convert?
no_files="$(wc -l $temp)"
no_files="${no_files%% *}"

# -r: "raw", i.e. do not strip backslashes
while read -r file
do

	# echo progress
	# escape backslashes so grep will see them
	pattern="${file//\\/\\\\}"
	file_no="$(grep -n "$pattern" $temp)"
	file_no="${file_no%%:*}"
	printf '\n%s\n' "$file_no of $no_files"

	in="$(cygpath "$file")"
	out="${in//$root_in/$root_out}"
	out="${out%.pdf}.txt"

	if [ ! -e "$out" ]
	then
		pdftotext "$in" "$out"
		if [ $? -eq 0 ]
		then
			printf '%s\n' "SUCCESSFULLY CONVERTED: ${in##*/}"
		fi
	else
		printf '%s\n' "ALREADY EXISTS: ${out##*/}"
	fi

done < $temp

rm $temp
