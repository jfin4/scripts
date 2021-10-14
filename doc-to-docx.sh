#!/bin/sh
# convert doc files to docx
# intermediate step before converting docx to txt for easy searching

if [ -z "$1" ]
then
	printf "%s\n" "Usage: $0 <dir>"
	exit
fi

root_in="$1"
root_out="${1}-docx"

# create list of files to convert
temp=$(mktemp)
fd -e doc . "$root_in" > $temp

# how many files to convert?
no_files="$(wc -l $temp)"
no_files="${no_files%% *}"

wordconv="/c/Program Files/Microsoft Office/root/Office16/Wordconv.exe"

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
	base_out="${base_in%.doc}.docx"
	dir_in="${full_in%/*}"
	dir_out="${dir_in//$root_in/$root_out}"
	full_out="$dir_out/$base_out"

	if [ ! -e "$full_out" ]
	then
		"$wordconv" -oice -nme "$full_in" "$dir_out/$base_out"
		if [ $? -eq 0 ]
		then
			printf '%s\n' "SUCCESSFULLY CONVERTED: $base_in"
		else
			printf '%s\n' "FAILED TO CONVERT: $base_in"
		fi
	else
		printf '%s\n' "ALREADY EXISTS: $base_out"
	fi

done < $temp

rm $temp
