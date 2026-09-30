#!/system/bin/sh
ui_print "- Installing Doze Whitelist Cleanup v1.1"
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
ui_print "- Edit remove.list in the module folder to change what is removed"
ui_print "- Reboot to activate; see last_boot.log for logs"
