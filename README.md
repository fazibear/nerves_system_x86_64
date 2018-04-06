# [WIP] Generic x86_64 System with XORG

[![CircleCI](https://circleci.com/gh/nerves-project/nerves_system_x86_64/tree/master.svg?style=svg)](https://circleci.com/gh/nerves-project/nerves_system_x86_64/tree/master)
[![Hex version](https://img.shields.io/hexpm/v/nerves_system_x86_64.svg "Hex version")](https://hex.pm/packages/nerves_system_x86_64)

This is the base Nerves System configuration for a generic x86_64 system.

| Feature              | Description                     |
| -------------------- | ------------------------------- |
| CPU                  | Intel                           |
| Memory               | 512 MB+ DRAM                    |
| Storage              | Hard disk/SSD/etc. (/dev/sda)   |
| Linux kernel         | 4.13                            |
| IEx terminal         | Display - tty0                  |
| Hardware I/O         | None                            |
| Ethernet             | Yes                             |

Please contact me about this if you're really interested in it. I don't
maintain it, and unless you really dig through the code, it's not going
to be obvious how it works. I'm happy to help if you're really interested.

## Root disk naming

If you have multiple SSDs, or other devices connected, it's
possible that Linux will enumerate those devices in a nondeterministic order.
This can be mitigated by using `udev` to populate the `/dev/disks/by-*`
directories, but even this can be inconvenient when you just want to refer to
the drive that provides the root filesystem. To address this, `erlinit` creates
`/dev/rootdisk0`, `/dev/rootdisk0p1`, etc. and symlinks them to the expected
devices. For example, if your root file system is on `/dev/mmcblk0p1`, you'll
get a symlink from `/dev/rootdisk0p1` to `/dev/mmcblk0p1` and the whole disk
will be `/dev/rootdisk0`. Similarly, if the root filesystem is on `/dev/sdb1`,
you'd still get `/dev/rootdisk0p1` and `/dev/rootdisk0` and they'd by symlinked
to `/dev/sdb1` and `/dev/sdb` respectively.
