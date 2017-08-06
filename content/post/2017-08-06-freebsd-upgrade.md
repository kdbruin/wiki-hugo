+++
title = "Upgrade to FreeBSD 11.1"
date = 2017-08-06T10:04:21+02:00
draft = true
tags = []
topics = []
description = ""
+++

As FreeBSD 11.1-RELEASE is now available, it is time to upgrade my system. As I've running several jails and also use Poudriere for building my own packages the process is a bit more complicated than the standard upgrade process.

<!--more-->

## Updating the host OS

The main host can be upgraded using the standard method of

```
root@filevault$ freebsd-update -r 11.1-RELEASE upgrade
root@filevault$ freebsd-update install
```

These commands download the new release and perform the first part of the installation of the new release. After the reboot run ```freebsd-update install``` again for the second part of the upgrade. When this is done it will ask to reinstall any packages you have installed and run ```freebsd-update install``` once more to finish the installation.

## Updating the build jail

Next we need to update the packages but to do so we need to update the poudriere jail used to build the packages.

1. Run

    ```root@filevault$ iocage fetch```
    
    to fetch the new release. This is not a required step at this point but I like to do this so the new release is also available for new jails.
1. Stop the poudriere jail using

    ```root@filevault$ iocage stop poudriere```
1. Upgrade the poudriere jail to the new release with

    ```root@filevault$ iocage upgrade -r 11.1-RELEASE poudriere```
    
    This will use ```freebsd-update``` to upgrade the jail and takes a while.

After the jail upgrade is completed we start the new jail and do the same upgrade for the jails poudriere is using to build the packages. The following set of commands take care of this:

```
root@filevault$ iocage start poudriere
root@filevault$ iocage console poudriere

root@poudriere# poudriere jail -j 11amd64 -u -t 11.1-RELEASE
```

The last command will take quite some time to complete. After the build jail is updated we can rebuild all packages using:

```
root@poudriere# poudriere options -j 11amd64 -f /usr/local/etc/poudriere.d/11amd64.pkglist -c
root@poudriere# poudriere bulk -j 11amd64 -f /usr/local/etc/poudriere.d/11amd64.pkglist
```

Depending on the number of packages this can take a few hours to complete.

## Finishing the host OS upgrade

After all packages are rebuild we need to reinstall all packages.