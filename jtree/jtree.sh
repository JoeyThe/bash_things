#!/usr/bin/bash
# JTree
jtree () {
	# Make sure there are at most two arguments
	if [ $# -gt 2 ]; then
		echo Too many arguments
		return 1
	fi
	# Variables
	local depth="-maxdepth 1"
	local dir="."
	local gives_dir=false

	# Loop through arguments
	for item in "$@"; do
		# Set recursive
		if [ "$item" == "-r" ]; then
			depth=""
		else
			# Determine if the path given is an absolute or relative one
			local first_char=$(printf %.1s "$item")
			if [ "$first_char" != "/" ]; then
				# If relative, prefix with current working directory
				dir="$(pwd)"/$item
			else
				dir="$item"
			fi

			# Check if the directory exists 
			if [ ! -d $dir ]; then
				echo Not a directory
				return 1
			fi
			# Because of the sed happening later, we need to get rid of the last slash
			gives_dir=true
			local last_char="${dir: -1}"
			if [ $last_char == "/" ]; then
				dir=${dir::-1}
			fi
		fi
	done

	# Print tree based on whether a directory was provided or not
	if $gives_dir; then
		echo -e $(find $dir $depth -printf "%p ;%Y; \\n" | sed -re "2,\$s:$dir::" -e '2,$s:[^/\n]*/:\\t:g' -e 's:(^.*)\\t:\1\|~→ :g' -e 's:(^.*→)(.*);f;:\1\\033[0;32m\2\\033[0m:g' -e 's:(^.*→)(.*);d;:\1\\033[0;34m\2\\033[0m:g' -e 's:(^.*):\1\\n:g' -e '1,$s:(^.*);d;:\1:')
	else
		echo -e $(find $dir $depth -printf "%p ;%Y; \\n" | sed -re '2,$s:./::1' -e '2,$s:(^.):/\1:' -e '2,$s:[^/\n]*/:\\t:g' -e 's:(^.*)\\t:\1\|~→ :g' -e 's:(^.*→)(.*);f;:\1\\033[0;32m\2\\033[0m:g' -e 's:(^.*→)(.*);d;:\1\\033[0;34m\2\\033[0m:g' -e 's:(^.*):\1\\n:g' -e '1,$s:(^.*);d;:\1:')
	fi
	return 0
}
