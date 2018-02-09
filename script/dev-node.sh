#! /bin/bash

VENDOR_ID="$(echo "$1" | awk '-F:' '{ print $1 }')"
PRODUCT_ID="$(echo "$1" | awk '-F:' '{ print $2 }')"

if [ -z "$VENDOR_ID" ] || [ -z "$PRODUCT_ID" ] ; then
    >&2 echo "You must specify a device identifier in the format xxxx:yyyy"
    exit 1
fi

echo "Nodes for $VENDOR_ID:$PRODUCT_ID"

find /sys/devices -name uevent | {
    readarray -t uevents              

    for u in "${uevents[@]}"; do
        path="${u%/uevent}"
        while [ "$path" != "/sys/devices" ] && ! [ -f "$path"/idVendor ]; do
            path="${path%/*}"
        done

        [ "$path" != "/sys/devices" ] && read readValue < "$path"/idVendor && [ "$readValue" = "$VENDOR_ID" ] && {
            if [ -n "$idProduct" ]; then
                read readValue < "$path"/idProduct && [ "$readValue" = "$PRODUCT_ID" ]
            fi
        } && echo "$u"
    done
} | {
    readarray -t uevents              

    [ ${#uevents[@]} -gt 0 ] && sed -n 's,DEVNAME=\(.*\),/dev/\1,p' "${uevents[@]}"
}
