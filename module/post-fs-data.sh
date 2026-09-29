#!/system/bin/sh

MODDIR=${0%/*}
SRC="$MODDIR/sys_deviceidle_whitelist.xml"
DST="/my_region/etc/battery/sys_deviceidle_whitelist.xml"

while [ ! -d /my_region/etc/battery ]; do
    sleep 1
done

while [ ! -f "$DST" ]; do
    sleep 1
done

mount --bind "$SRC" "$DST"