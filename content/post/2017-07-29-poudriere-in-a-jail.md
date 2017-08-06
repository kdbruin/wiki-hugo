+++
title = "Poudriere In A Jail"
date = 2017-07-29T14:26:44+02:00
draft = true
tags = []
topics = []
description = ""
+++

On my previous FreeBSD installation I used to build all packages using ports but this could be a very time consuming operation and also dependencies could get mixed up as packages were updated. To avoid this it is recommended to install packages from a repository but these are build using the default options. Using ```ports-mgmt/poudriere``` it is possible to create your own package repository where package options can be customized.

<!--more-->

## Creating a poudriere jail

We use ```iocage``` to create a jail for poudriere. As we want to use ZFS datasets for the underlying jails, we need to prepare the datasets such that they can be used from within the poudriere jail. Also note that since there is a 77 character limit to the name of a ZFS dataset, we use a short name for the dataset.

```
root@filevault$ zfs create -o jailed=on zroot/p
```

The option ```jailed=on``` allows the dataset to be manipulated from within a jail.

Now create the jail:

```
root@filevault$ iocage create \
    --release 11.0-RELEASE \
    --name poudriere \
    boot="on" \
    vnet="off" \
    ip4_addr="re0|172.16.123.50/24,lo0|127.0.0.1" \
    host_hostname="poudriere.home.lan" \
    jail_zfs="on" \
    jail_zfs_dataset="p" \
    enforce_statfs="1" \
    allow_mount="1" \
    allow_mount_devfs="1" \
    allow_mount_nullfs="1" \
    allow_mount_tmpfs="1" \
    allow_mount_procfs="1" \
    allow_mount_zfs="1" \
    allow_chflags="1" \
    allow_raw_sockets="1" \
    allow_socket_af="1" \
    allow_sysvipc="1" \
    children_max="10" \
    mount_devfs="1"
```

Some explanation on the various properties used:

- We set the IPv4 address and hostname of the jail. Note that we force the netmask to a /24 network and include localhost as this is required by poudriere.
- Use the ZFS dataset created earlier.
- Allow the jail to get information on its mountpoint. This is needed to be able to mount additional filesystems within the jail.
- Allow the jail to mount filesystems, including the listed filesystems.
- Allow the use of ```chflags``` as required by poudriere.
- Allow some networking to be passed to the build jails poudriere uses.
- Allow a maximum of 10 child jails.
- Mount the ```devfs``` filesystem as it is needed for ZFS and poudriere.

After the jail is created we can start the jail and open a console for this jail:

```
root@filevault$ iocage start poudriere
root@filevault$ iocage console poudriere
```

## Poudriere setup

Next we need to install and configure poudriere. As the default package repository uses quarterly updates now, we need to update the repository to use the latest updates. For this we create the file ```/usr/local/etc/pkg/repos/FreeBSD.conf``` inside the jail:

```
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
```

For now, set ```enabled``` to ```yes``` so we can install packages from the default repository. After we have completed the poudriere setup we switch to using our own repository.

Install the poudriere package and allow ```pkg``` to install itself:

```
root@poudriere# pkg install ports-mgmt/poudriere
```

A example configuration is placed in ```/usr/local/etc/poudriere.conf.sample``` with an explanation of the various fields. Create the file ```/usr/local/etc/poudriere.conf``` with the following content:

```
# Poudriere configuration file

ZPOOL=zroot
ZROOTFS=/p
FREEBSD_HOST=ftp://ftp.nl.freebsd.org
RESOLV_CONF=/etc/resolv.conf
BASEFS=/poudriere
POUDRIERE_DATA=${BASEFS}/data
USE_PORTLINT=no
USE_TMPFS=all
DISTFILES_CACHE=/poudriere/distfiles
CHECK_CHANGED_OPTIONS=verbose
CHECK_CHANGED_DEPS=yes
PKG_REPO_SIGNING_KEY=/usr/local/etc/pki/poudriere/poudriere.key
CCACHE_DIR=/var/cache/ccache
WRKDIR_ARCHIVE_FORMAT=tbz
NOLINUX=yes
URL_BASE=http://poudriere.home.lan/poudriere/
ATOMIC_PACKAGE_REPOSITORY=yes
COMMIT_PACKAGES_ON_FAILURE=yes
KEEP_OLD_PACKAGES=yes
KEEP_OLD_PACKAGES_COUNT=3
```

Aside from the poudriere package we need to install the following additional packages:

- ```devel/ccache```
- ```ports-mgmt/dialog4ports```

From here we can follow the directions from the [FreeBSD handbook](https://www.freebsd.org/doc/handbook/ports-poudriere.html) to setup the poudriere build system.

1. Create a build jail using the same release as our host:

    ```root@poudriere# poudriere jail -c -j 11amd64 -v 11.0-RELEASE```
1. Create the default ports tree:

    ```root@poudriere# poudriere ports -c```
1. Create ```/usr/local/etc/poudriere.d/11amd64.pkglist``` with a list of packages we want to build:

    ```
    ports-mgmt/pkg
    ports-mgmt/poudriere
    www/nginx
    devel/ccache
    ports-mgmt/dialog4ports
    ```
1. Create ```/usr/local/etc/poudriere.d/make.conf``` for the default build options:

    ```
    # Enable the following features
    WITH_PKGNG=yes
    USE_PORTMASTER=yes
    WITH_SSP_PORTS=yes

    # Use the OpenSSL port version where possible
    DEFAULT_VERSIONS+=      ssl=openssl

    # Default versions for some programs
    DEFAULT_VERSIONS+=      bdb=5
    DEFAULT_VERSIONS+=      mysql=10.2m
    DEFAULT_VERSIONS+=      perl5=5.24
    DEFAULT_VERSIONS+=      python=2.7
    DEFAULT_VERSIONS+=      python2=2.7
    DEFAULT_VERSIONS+=      python3=3.6
    DEFAULT_VERSIONS+=      ruby=2.4

    # Enable some features by default
    OPTIONS_SET+=   MANPAGES
    OPTIONS_SET+=   VP8
    OPTIONS_SET+=   ICONV
    OPTIONS_SET+=   GSSAPI_MIT
    OPTIONS_SET+=   READLINE_PORT

    # Disable some features by default
    OPTIONS_UNSET+= X11
    OPTIONS_UNSET+= CUPS
    OPTIONS_UNSET+= LDAP
    OPTIONS_UNSET+= TCL
    OPTIONS_UNSET+= WXGTK
    OPTIONS_UNSET+= OPENGL
    OPTIONS_UNSET+= EGL
    OPTIONS_UNSET+= NLS
    OPTIONS_UNSET+= EXAMPLES
    OPTIONS_UNSET+= LUA
    OPTIONS_UNSET+= DEBUG
    OPTIONS_UNSET+= SOUND
    OPTIONS_UNSET+= ALSA
    OPTIONS_UNSET+= PULSEAUDIO
    OPTIONS_UNSET+= DOCBOOK
    OPTIONS_UNSET+= GSSAPI_BASE
    ```
1. Configure all ports using:

    ```root@poudriere# poudriere options -j 11amd64 -f /usr/local/etc/poudriere.d/11amd64.pkglist```
1. Build all packages:

    ```root@poudriere# poudriere bulk -j 11amd64 -f /usr/local/etc/poudriere.d/11amd64.pkglist```

## Enable the web client



## References

I've used the following resources to set this all up:

- [poudriere in a jail with zfs](http://zero-knowledge.org/post/126/)
- [Poudriere in a jail](http://www.allanjude.com/blog/2013-10-05_poudriere_jail)
- [FreeBSD handbook](https://www.freebsd.org/doc/handbook/ports-poudriere.html)
