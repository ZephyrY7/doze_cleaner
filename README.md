# Doze Whitelist Cleanup

KernelSU module for OPlus/ColorOS devices that allows you to **remove or add packages** from the OPlus DeviceIdle/Doze whitelist.

## Requirements

* Rooted OPlus/ColorOS device
* KernelSU
* A device using:

  ```text
  /my_region/etc/battery/sys_deviceidle_whitelist.xml
  ```

## How It Works

OPlus uses:

```text
/my_region/etc/battery/sys_deviceidle_whitelist.xml
```

as a source for its local DeviceIdle whitelist:

```text
/data/oplus/os/battery/doze_wl_local.xml
```

On every boot, this module:

1. Reads the **live stock** `sys_deviceidle_whitelist.xml`.
2. Removes packages listed in `remove.list`.
3. Adds packages listed in `add.list` if they are not already present.
4. Validates the resulting configuration.
5. Bind-mounts the filtered configuration over the original file.

It rebuilds the config from the stock file on every boot, changes made by OTA updates to the original whitelist can be preserved automatically.
runs once during boot and **no background service**.

## Configuration

### `remove.list`
Packages to remove
### `add.list`
Packages to add

## Verify

After reboot:

```sh
su
dumpsys deviceidle whitelist
```

You can also check the generated OPlus configuration:

```sh
cat /data/oplus/os/battery/doze_wl_local.xml
```

The module's log is available at:

```text
/data/adb/modules/doze-wl-clean/last_boot.log
```

## Disclaimer

This module modifies OPlus battery/Doze configuration. Behavior may vary between different OPlus/ColorOS versions, devices, and regional firmware configurations.

Keep a backup of the original configuration before installing.

Use at your own risk.
