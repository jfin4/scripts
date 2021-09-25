#!/bin/sh
# convert docx files to text for easy searching

if [ -z "$1" ]
then
	printf "%s\n" "Usage: $0 <dir>"
	exit
fi

root_in="${1%-*}"
root_out="${1}-text"

# create list of files to convert
temp=$(mktemp)
fd -e docx . "$root_in" > $temp

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

	full_in="$(cygpath "$file")"
	base_in="${full_in##*/}"
	base_out="${base_in%.docx}.txt"
	dir_in="${full_in%/*}"
	dir_out="${dir_in//$root_in/$root_out}"
	full_out="$dir_out/$base_out"

	if [ ! -e "$full_out" ]
	then
		docx2txt "$full_in"
		if [ $? -eq 0 ]
		then
			# mv -n: no clobber
			mv -n "$dir_in/$base_out" "$dir_out" \
			&& printf '%s\n' "SUCCESSFULLY CONVERTED: $base_in"
		fi
	else
		printf '%s\n' "ALREADY EXISTS: $base_out"
	fi

done < $temp

rm $temp
