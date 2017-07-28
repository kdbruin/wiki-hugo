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

## Setup of a jail

Although underneath the jail itself is no different between the various setup types, they can provide some additional benifits. The following solutions are available:

* Setup using the standard jail configuration
* Using ```ezjail```
* Using ```iocage```

And there will be probably many more ways to create and maintain jails.

While ```ezjail``` is widely used I wanted to try out ```iocage``` as it a more recent development and is getting some more attention.