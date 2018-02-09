#! /bin/bash

if [ -n "$1" ]; then
    2>/dev/null find -L /sys/class/$1 -maxdepth 2 -mindepth 2 -name uevent -exec realpath "{}" +
else
    find /sys/devices -name uevent
fi | {
    if [ -n "$2" ]; then
	readarray -t uevents              

	for u in "${uevents[@]}"; do
	    path="${u%/uevent}"
	    while [ "$path" != "/sys/devices" ] && ! [ -f "$path"/idVendor ]; do
		path="${path%/*}"
	    done

	    [ "$path" != "/sys/devices" ] && read readValue < "$path"/idVendor && [ "$readValue" = "$2" ] && {
		if [ -n "$idProduct" ]; then
		    read readValue < "$path"/idProduct && [ "$readValue" = "$3" ]
		fi
	    } && echo "$u"
	done
    else
	cat
    fi
} | {
    readarray -t uevents              

    [ ${#uevents[@]} -gt 0 ] && sed -n 's,DEVNAME=\(.*\),/dev/\1,p' "${uevents[@]}"
}
