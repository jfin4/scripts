#!/bin/zsh

out=index.csv
if [ -e $out ]; then
    rm $out
fi
printf '%s,%s,%s\n' "Date" "Title" "Page" >> $out

total_pages=0
for f in "$@"; do
    base=${f#*/}
    date=${base%%_*}
    date=${date//-/\/}
    title=${base#*_}
    title=${title%.*}
    title=${title//_/ }
    page_no=$(( total_pages + 1 ))
    file_pages=$(pdfinfo $f | awk '/^Pages:/ { print $2 }')
    total_pages=$(( total_pages + file_pages ))
    printf '%s,%s,%s\n' "$date" "$title" "$page_no" >> $out
done

