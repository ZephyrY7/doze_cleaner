#!/system/bin/sh
# Bind-mounts a filtered copy of the OPlus deviceidle whitelist config over the
# stock file: removes packages listed in remove.list, adds packages listed in
# add.list (if not already present). Regenerated from the live stock file on
# every boot

MODDIR=${0%/*}
DST="/my_region/etc/battery/sys_deviceidle_whitelist.xml"
REMOVE="$MODDIR/remove.list"
ADD="$MODDIR/add.list"
OUT="$MODDIR/sys_deviceidle_whitelist.xml"
TMP="$MODDIR/.sys_deviceidle_whitelist.xml.tmp"
PAT="$MODDIR/.patterns"
LOG="$MODDIR/last_boot.log"

log() { echo "$(date '+%m-%d %H:%M:%S') $*" >> "$LOG"; }
bail() { log "$1, not mounting"; rm -f "$TMP" "$PAT"; exit 0; }

: > "$LOG"

# Re-run within the same boot
grep -q " $DST " /proc/mounts && { log "already mounted, skipping"; exit 0; }

# Bounded wait
i=0
while [ ! -f "$DST" ] && [ "$i" -lt 10 ]; do
    sleep 1
    i=$((i + 1))
done
[ -f "$DST" ] || bail "stock file missing after 10s"

ORIG_N=$(grep -c '<wl>' "$DST")

# --- REMOVE ---
if [ -f "$REMOVE" ]; then
    : > "$PAT"
    while IFS= read -r p || [ -n "$p" ]; do
        p="$(echo "$p" | sed 's/#.*//' | tr -d '[:space:]')"
        [ -n "$p" ] && echo "<wl>$p</wl>" >> "$PAT"
    done < "$REMOVE"
    if [ -s "$PAT" ]; then
        grep -v -F -f "$PAT" "$DST" > "$TMP" 2>>"$LOG"
    else
        cp "$DST" "$TMP"
    fi
else
    cp "$DST" "$TMP"
fi

# --- ADD ---
if [ -f "$ADD" ]; then
    while IFS= read -r p || [ -n "$p" ]; do
        p="$(echo "$p" | sed 's/#.*//' | tr -d '[:space:]')"
        [ -z "$p" ] && continue
        grep -q ">$p<" "$TMP" || sed -i "s#</filter-conf>#    <wl>$p</wl>\r\n</filter-conf>#" "$TMP"
    done < "$ADD"
fi

NEW_N=$(grep -c '<wl>' "$TMP")
log "stock entries: $ORIG_N, filtered entries: $NEW_N"

# --- validation ---
[ "$NEW_N" -ne "$ORIG_N" ] || bail "no change made"
[ "$NEW_N" -ge 20 ]        || bail "too few entries left ($NEW_N)"
grep -q '<filter-conf>' "$TMP" && grep -q '</filter-conf>' "$TMP" || bail "malformed output"

# Guards against a typo in remove.list
for c in com.android.phone com.android.systemui com.android.bluetooth \
         com.google.android.gms com.android.providers.telephony \
         com.android.providers.contacts com.android.settings; do
    grep -q ">$c<" "$TMP" || bail "essential entry $c missing"
done

# Match the stock file's SELinux label.
CTX=$(/system/bin/ls -Z "$DST" 2>/dev/null | awk '{print $1}')
case "$CTX" in
    u:object_r:*) ;;
    *) bail "could not read SELinux context ($CTX)" ;;
esac

mv -f "$TMP" "$OUT"
chmod 644 "$OUT"
/system/bin/chcon "$CTX" "$OUT" 2>>"$LOG" || bail "chcon failed"

mount -o bind "$OUT" "$DST" 2>>"$LOG" || bail "mount failed"

if grep -q " $DST " /proc/mounts; then
    log "mounted OK ($NEW_N entries, context $CTX)"
else
    log "mount command succeeded but not visible in /proc/mounts"
fi
rm -f "$PAT"
