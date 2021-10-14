#!/bin/sh

# Rsync wrapper used primarily to sync local copies of networked drives

# Typical rsync options are -av or --archive --verbose
# The --archive option is itself a bundle of other options:
# 	--recursive
# 	--links 	copy symlinks as symlinks
# 	--perms 
# 	--times 	preserve modification times
# 	--group
# 	--owner
# 	--devices
# 	--specials 	preserve special files, e.g. named sockets
 
# We have ommitted the --links, --devices, and --specials options since msys2
# does not support symlinks and the networked drives do not contain any device
# or special files that we are interested in.

if [ -z "$1" -o "$1" == "-h" ]
then
	printf "Usage: $0 <dir>\n"
	exit
fi

dir="$1"

rsync\
	--recursive\
	--perms\
	--times\
	--group\
	--owner\
	--verbose\
	--delete\
	--\
	"/r/RB3/Shared/$dir/"\
	"/home/jfin/waterboard/rdrive/$dir/"
