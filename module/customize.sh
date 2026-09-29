#!/system/bin/sh
ui_print "- Installing Doze Whitelist Cleanup"

set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/sys_deviceidle_whitelist.xml" 0 0 0644

ui_print "- Installation complete"
ui_print "- Reboot to activate"
