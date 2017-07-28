+++
title = "A Clean Freebsd Install"
date = 2017-07-28T12:00:50+02:00
draft = true
tags = []
topics = []
description = ""
+++

After some years of running FreeBSD the system became a bit poluted with packages no longer in use. Also, as there was a new release available (11.0) and I wanted to upgrade my system I decided to do a clean install instead of the in-place upgrade.

<!--more-->

## Installation media

Follow the instructions from the [FreeBSD Handbook](https://www.freebsd.org/doc/handbook/) to create a USB installation stick. I used the ```memstick`` image.

## Preparations

Although I wanted to do a clean install I didn't want to loose all my configuration settings. First create snapshots we can send to another ZFS pool:

```
zfs snapshot -r zroot/ROOT@preupgrade
zfs snapshot -r zroot/home@preupgrade
```

Next, send the snapshots to the backup pool:

```
zfs send -R zroot/ROOT@preupgrade | zfs receive -F vault/BACKUP-ROOT
zfs send -R zroot/home@preupgrade | zfs receive -F vault/BACKUP-home
```

Also change the mountpoints so the backups don't mount at the original mountpoints

```
zfs set -r mountpoint=none vault/BACKUP-ROOT
zfs set -r mountpoint=none vault/BACKUP-home
```

## FreeBSD installation

Next start the installation and follow the steps from the handbook. For the partitioning I choose the ```ZFS``` option. This will create a Root-on-ZFS scheme that allows for easy upgrades using the ```beadm``` utility.

## System configuration

After the installation is complete it is time to start installing the necessary packages again. Instead of building from ports I opted to install packages. But instead of downloading these from the official site I used ```poudriere``` to build the packages myself so I can still change the default build options. More on this in a next post.