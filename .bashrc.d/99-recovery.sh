#! /bin/bash
mount_chroot () {
    sudo mount "$1" "$2" || return $?
    for each in dev proc sys run ; do
        sudo mount --bind "/$each" "$2/$each"
    done
}
