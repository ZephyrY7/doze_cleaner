# Doze Whitelist Cleanup

Module for OPlus/ColorOS devices that removes selected third-party applications from the system DeviceIdle/Doze whitelist.

## Requirements

* Rooted OPlus/ColorOS device
* KernelSU
* A device using the OPlus `my_region` battery configuration

## Verify

After reboot:

```sh
su
dumpsys deviceidle whitelist
```

## Disclaimer

This module modifies OPlus battery/Doze configuration. Behavior may vary between ColorOS/OPlus versions and devices.

Keep a backup of the original configuration before installing.

Use at your own risk.
