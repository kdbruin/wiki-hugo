+++
description = ""
date = "2016-10-23T10:59:52+02:00"
title = "Rsync Backup"
draft = false
tags = []
topics = []

+++

Having a proper backup of your work is essential. Although every OS X and macOS system comes with Time Machine this is not always the best solution. In this article we describe how we can use rsync to create a backup.

<!--more-->

## Why rsync?

As I want to store the backups on my NAS running FreeBSD I need to be able to transfer the files between both systems. It is possible to use Time Machine over AFP, NFS or Samba but after playing with this I found it slow and cumbersome. So I started looking for another solution and found [rsnapshot](http://www.rsnapshot.org) that uses rsync underneath to handle all stuff.

## Running the rsync daemon

Using this set of tools requires that the Mac system has a running rsync daemon. As I don't have the Server extension I needed to set this up myself. After some searching the web I found a nice solution at http://bahut.alma.ch/2013/01/rsync-server-daemon-on-mac-os-x.html. Based on this I created the following file:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>rsync</string>
        <key>Program</key>
        <string>/usr/local/bin/rsync</string>
        <key>ProgramArguments</key>
        <array>
                <string>/usr/local/bin/rsync</string>
                <string>--daemon</string>
                <string>--config=/usr/local/etc/rsyncd.conf</string>
        </array>
        <key>inetdCompatibility</key>
        <dict>
                <key>Wait</key>
                <false/>
        </dict>
        <key>Sockets</key>
        <dict>
                <key>Listeners</key>
                <dict>
                        <key>SockServiceName</key>
                        <string>rsync</string>
                        <key>SockType</key>
                        <string>stream</string>
                </dict>
        </dict>
</dict>
</plist>
```

This will start the rsync daemon at system startup. Place this file in the ```/Library/LaunchDaemons``` directory as e.g. ```org.samba.rsync.plist``` and set the correct permissions on the file:

```
% sudo cp ~/rsync.plist /Library/LaunchDaemons/org.samba.rsync.plist
% sudo chmod 644 /Library/LaunchDaemons/org.samba.rsync.plist
```

The configuration of the rsync daemon is placed in ```/usr/local/etc/rsyncd.conf```. Here I define the rsync names for the locations I want to backup:

```
[kdb]
        path = /Users/kdb
        hosts allow = 172.16.123.0/24
        uid = kdb
        gid = staff
        read only = false
        comment = My home

[usb]
        path = /Volumes/Offline Backup
        hosts allow = 172.16.123.0/24
        uid = kdb
        gid = staff
        read only = false
        comment = USB Backup Disk
```

Note that security is just on the network level but could be changed to something more secure. For my situation this is sufficient.

Install the rsync daemon using the following commands in a Terminal window:

```
% sudo launchctl load /Library/LaunchDaemons/org.samba.rsync.plist
% sudo launchctl start org.samba.rsync
```

This will load and start the rsync daemon. To see if the daemon is running, use the following commands:

```
% launchctl list | grep rsync
-   0   org.samba.rsync
```

To remove the rsync daemon:

```
% sudo launchctl unload /Library/LaunchDaemons/org.samba.rsync.plist
% sudo killall rsync
```

## Setting up the FreeBSD server

On the FreeBSD server as ```root``` add a dedicated user and group for the backup process:

```
% su -
$ pw groupadd timemachine
$ pw useradd timemachine -g timemachine -d /vault/timemachine -m -s /usr/sbin/nologin
```

This will add a user and group ```timemachine``` with a home directory set but no login shell. Next, login as the new user and create the necessary directories:

```
$ su -m timemachine
timemachine% cd /vault/timemachine
timemachine% mkdir bin etc logs snapshots
```

### SSH keys

For proper authentication and encryption rsnapshot uses SSH so we need to create the proper keys:

```
timemachine% ssh-keygen -t rsa
```

Leave the passphrase empty so only the SSH key is used for authentication. Now copy the generated public key to the machines that need to be backed up. Use the ```ssh-copy-id``` utility for this:

```
timemachine% ssh-copy-id /vault/timemachine/.ssh/id_rsa.pub kdb@172.16.123.7
```

When prompted supply the password for the remote user. This will add the public key to the ```authorized_keys``` file on the remote system.

### rsnapshot

For each machine to backup I created a configuration file. For example for my iMac I created ```etc/rsnapshot-imac.conf``` with the following content:

```
config_version  1.2
snapshot_root   /vault/timemachine/snapshots/imac

cmd_cp          /usr/local/bin/gcp
cmd_rm          /usr/local/bin/grm
cmd_rsync       /usr/local/bin/rsync
cmd_ssh         /usr/bin/ssh
cmd_logger      /usr/bin/logger

retain          daily   14
#retain         daily   7
#retain         weekly  4
#retain         monthly 3

link_dest       1
# sync_first    1

verbose         2
loglevel        3
logfile         /vault/timemachine/logs/rsnapshot-imac.log
lockfile        /vault/timemachine/rsnapshot-imac.pid

exclude_file    /vault/timemachine/etc/excludes-imac.conf

backup          rsync://172.16.123.7/kdb/       imac/
backup          rsync://172.16.123.7/usb/       imac-usb/
```

See the rsnapshot documentation for a complete explanation for each option. The syntax of the configuration can be checked using the following command:

```
timemachine% rsnapshot -c /vault/timemachine/etc/rsnapshot-imac.conf configtest
```

I've opted to disable the non-daily backups as they assume that the system being backed up is always available. As this is not the case for me I increased the daily backups to 14. The backup itself is initiated by the following script:

```
#! /bin/sh
#
# Use rsnapshot to create a backup of my iMac.

# Settings
BASEDIR=/vault/timemachine
REMOTE_HOST=imac
REMOTE_DOMAIN=localdomain
RSNAPSHOT_CONFIG=${BASEDIR}/etc/rsnapshot-${REMOTE_HOST}.conf

# Check if the remote host is on
/usr/local/sbin/fping -a ${REMOTE_HOST}.${REMOTE_DOMAIN} >/dev/null 2>&1
if [ $? -ne 0 ]; then
        echo ${REMOTE_HOST}.${REMOTE_DOMAIN} not online, skipping backup.
        exit 0
fi

# Check for required argument
if [ -z "$1" ]; then
        echo "Missing required argument (hourly, daily, weekly, monthly), skipping backup."
        exit 0
fi

# Run the backup
date "+Starting $1 backup: %Y-%m-%d %H:%M:%S"
/usr/local/bin/rsnapshot -V -c ${RSNAPSHOT_CONFIG} "$1"
date "+Finished backup: %Y-%m-%d %H:%M:%S"
```

This script is placed in ```bin/backup-imac.sh``` and executed daily through crontab. The script will check if the remote system is available before the backup is initiated.

### Exclusing files from the backup

In the file ```etc/excludes-imac.conf``` I've excluded several directories and file types to prevent unwanted files to be backed up. This is based on the exclusions from Apple's Time Machine, Backblaze and personal experiences. Adapt to suite your own needs:

```
# Common file extensions
*~
*.appicon
*.appinfo
*.cab
*.cof
*.cop
*.cot
*.dl_
*.dll
*.dmg
*.drk
*.exe
*.fdd
*.hdd
*.hds
*.iso
*.ithmb
*.log
*.mem
*.menudata
*.msi
*.nvram
*.o
*.ost
*.part
*.pva
*.pvi
*.pvm
*.pvs
*.qtch
*.sparseimage
*.sys
*.vdi
*.vhd
*.vmc
*.vmdk
*.vmem
*.vmsd
*.vmsn
*.vmss
*.vmx
*.vmxf
*.vo1
*.vo2
*.vsv
*.vud
*.wab
*.wim

# Capture One
/hubiC/Archived/Capture One Sessions/**/Output
/Pictures/Sessions/**/Output

# 1Password backups and old stuff
/Documents/1Password/Backups/
/Library/Application Support/1Password/
/Library/Application Support/1Password 4/

# Aperture, iPhoto and Photos
*.aplibrary/Previews
*.aplibrary/Thumbnails
*.photolibrary/iPod Photo Cache
*.photolibrary/Previews
*.photolibrary/Thumbnails
*.photoslibrary/Previews
*.photoslibrary/Thumbnails

# Lightroom
* Previews.lrdata

# ON1 Photo 10
/Library/Application Support/ON1/ON1 Photo 10/PerfectBrowseCache/

# Books
/Documents/Books

# Cache directories
.[Cc]ache/
.[Cc]aches/
[Cc]ache/
[Cc]aches/

# Trash directories
.[Tt]rash/
[Tt]rash/

# Mounted USB disks
/.DocumentRevisions-V100
/.Spotlight-V100
/.TemporaryItems
/.Trashes
/.bzvol
/.fseventsd

# Unwanted stuff
/.android/avd
/.dropbox
/Applications
/Backup
/Backups
/Downloads
/Dropbox
/Google Drive
/Shared
/Sync
.DS_Store
[Tt]mp/

# Node and Bower stuff
/.node
/.node-gyp
/.npm
node_modules/
bower_components/

# Application stuff
/Library/Application Support/ExpanDrive/*/
/Library/Application Support/Google/Chrome/Safe Browsing*
/Library/Application Support/SyncServices/*/data.version
/Library/Logs
/Library/Mail/V[23]/MailData/Envelope Index
/Library/Mail/V[23]/MailData/Envelope Index-journal
/Library/Mail/V[23]/MailData/Envelope Index-shm
/Library/Mail/V[23]/MailData/Envelope Index-wal
/Library/Mail/V3/AosIMAP-*/
/Library/Mail/V3/IMAP-*/
/Library/Mirrors
/Library/PubSub/Database
/Library/PubSub/Downloads
/Library/PubSub/Feeds
/Library/Safari/HistoryIndex.sk
/Library/Safari/Icons.db
/Library/Safari/WebpageIcons.db
/Library/Saved Application State

# Multimedia
/Music/iTunes/Previous iTunes Libraries
/Music/iTunes/iTunes Media/Mobile Applications
/Music/iTunes/iTunes Media/Podcasts
/Music/Subscriptions
```

### Creating a backup

With the following command we can see what is executed by rsnapshot for a daily backup:

```
timemachine% rsnapshot -c etc/rsnapshot-imac.conf -t daily
```

To make an actual backup remove the ```-t``` option. Add the ```-v``` option for a more verbose output.

### Automatic backups

To create automatic backups we need to create a crontab entry for the backup command. We use our backup script instead of directly calling rsnapshot:

```
timemachine% crontab -e
```

Add the following lines to start a backup at 3:30AM and mail the output to the given user:

```
SHELL=/bin/sh
PATH=/usr/bin:/bin:/usr/local/bin
MAILTO=user@example.com

30 3 * * *	/vault/timemachine/bin/backup-imac.sh daily
```
