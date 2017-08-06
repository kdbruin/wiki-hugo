+++
title = "FreeBSD Jails"
date = 2017-07-28T14:29:44+02:00
draft = true
tags = []
topics = []
description = ""
+++

While Dockers are becoming more and more popular they are not really supported under FreeBSD. And why should they as the FreeBSD jail can accomplish the same functionality up to some level. While with Docker you can run Linux subsystems on non-Linux hosts, a FreeBSD jail runs FreeBSD in a restricted environment.

<!--more-->

## Jail management software

Although underneath the jail itself is no different between the various setup types, they can provide some additional benifits. The following solutions are available:

* Setup using the standard jail configuration
* Using ```ezjail```
* Using [```iocage```](https://github.com/iocage/iocage)

And there will be probably many more ways to create and maintain jails. While ```ezjail``` is widely used I wanted to try out ```iocage``` as it a more recent development and is getting some more attention. Also, it is actively maintained and updated.

## Setup of a jail

Using ```iocage``` you have several steps to take before you can create an actual jail. These steps are also explained in the [documentation](http://iocage.readthedocs.io/en/latest/genindex.html).

1. Assign a ZFS pool for the jail datasets. I'm using the root pool here:

    ```iocage activate zroot```

1. Fetch a FreeBSD release to be used for the jails:

    ```iocage fetch```

    Choose the default release as it corresponds to the release of the host OS.

Now we can start creating jails.

## Creating a jail

For the jail we need to make a few decisions, especially about networking. We can use shared IP networking or virtual networking. For the latter a custom kernel must be compiled that supports virtual networking. For my situation (and probably most other situations) shared IP networking is sufficient.

To create a jail issue the following command:

```iocage create --release 11.0-RELEASE```

This will create a standard jail running FreeBSD 11.0-RELEASE (or use the release fetched earlier). The jail will be identified using a complex UUID and when referencing the jail we need to use the UUID or abbreviated UUID (the first significant characters of the full UUID). A symbolic name can be assigned when creating the jail:

```iocage create --release 11.0-RELEASE --name myjail```

Properties of the jail can be listed using:

```iocage get all <JAIL | UUID>```

Instead of ```all``` a single property name can also be queried. See the ```jail``` manual page for a list of all properties.

Setting properties can be done using:

```iocage set <property> <JAIL | UUID>```

See some of the follow-up acticles on how to create and configure jails for various tasks.